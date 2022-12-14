# Thinking

В билде есть принципиально новая система планирования выполнения логики - `/datum/proc/think()`. Её главное отличие от `/datum/proc/Process()` - возможность указать время следующего вызова, а так же создавать сколько угодно аналогичных функции для любого объекта!

## Начало работы

Весь код который должен вызывать с некоторой переодичностью расположен в функции `think()` (по-аналогии как это сделано с `Process()`).

Понять как работать с `think()` можно на примере создания блоба (будет использоваться реальный код из билда).

Сделаем функцию который нужно будет вызывать каждую 1 секунду:

```dm
/obj/structure/blob/proc/life()
	if(health <= 0)
		die()
		return FALSE

	return TRUE
```

Возврат булева значение нужен что-бы можно было понять - жив ли ещё блоб или нет.

Теперь переопределим `think()`:

```dm
/obj/structure/blob/think()
	if(life())
		set_next_think(world.time + 1 SECOND)
```

Здесь, если после вызова `life()` блоб ещё жив - мы планируем вызов `think()` на секунду вперёд.

**Это важное отличие от `Process()`! Мы сам должны планировать вызов `think()` (в первом случае за нас это делает подсистема). Если `set_next_think` не будет вызван - то не будет вызван и `think()`.**

Теперь нужно начать процессить блоба после его инициализации. В случае использования `Process()` мы бы написали:

```dm
/obj/structure/blob/Initialize()
	. = ..()

	START_PROCESS(SSprocessing, src)
```

Но у нас `think()`. В принципе, можно его и вызвать:

```dm
/obj/structure/blob/Initialize()
	. = ..()

	think()
```

Это запустит `think()` и приведёт к `set_next_think`. Но рекомендуется делать всегда так:

```dm
/obj/structure/blob/Initialize()
	. = ..()

	set_next_think(world.time)
```

Это заставит запуститься `think()` в самое ближайшее время (но не сразу). Это особенно касается `New()` и `Initialize()` - там желательно выполнять минимум кода.

Теперь у нас `think()` будет вызываться пока блоб не умрёт, но что если нам надо обрабатывать ещё некоторый функционал, да и ещё не каждую секунду? Для этого есть контексты.

Напишем то что нужно вызывать с некоторой переодичностью:

```dm
/obj/structure/blob/proc/heal_think()
	heal()
	set_next_think_ctx("heal", world.time + BLOB_HEAL_COOLDOWN)

/obj/structure/blob/proc/attack_think()
	attack()
	set_next_think_ctx("attack", world.time + BLOB_ATTACK_COOLDOWN)

/obj/structure/blob/proc/expand_think()
	if(prob(BLOB_EXPAND_CHANCE))
		expand()
	
	set_next_think_ctx("expand", world.time + BLOB_EXPAND_COOLODNW)

/obj/structure/blob/proc/upgrade_think()
	if(prob(BLOB_UPGRADE_CHANCE) && upgrade())
		return 
	
	set_next_think_ctx("upgrade", world.time + BLOB_UPGRADE_COOLDOWN)
```

Здесь используется новая функция - `set_next_think_ctx`. Первый её аргумент - идентификатор, второй аргумент - время (аналогично первому аргументу функции `set_next_think`).

`set_next_think_ctx` - планирует вызов контекста с указанным идентификатором на нужное нам время.

Пока эти идентификаторы не привязаны к какой-либо функции и подсистема SSthink не может знать какую функцию надо вызывать для них.

Что-бы всё заработало нам нужно привязать контексты к их функциям:

```dm
/obj/structure/blob/Initialize()
	. = ..()

	set_next_think(world.time)
	add_think_ctx("heal", CALLBACK(src, .proc/heal_think), world.time)
	add_think_ctx("attack", CALLBACK(src, .proc/attack_think), world.time)
	add_think_ctx("expand", CALLBACK(src, .proc/expand_think), world.time)
	add_think_ctx("upgrade", CALLBACK(src, .proc/upgrade_think), world.time)
```

Здесь используем функцию `add_think_ctx` - первым аргументом передаём название контекста, вторым - "коллбэк" (что это и как с ним работать можно посмотреть на примере таймеров), третий аргумент - когда вызвать.

`add_think_ctx` необходимо вызвать только один раз для каждого идентификатора контекста! Повторный вызов для уже существующего контекста вызовет рантайм.

И это всё. В случае использования `Process()` - нам нужно было бы выполнить `STOP_PROCESSING` при удалении блоба. Но в случае использования `think()` это не требуется! При удалении все контексты и коллбэки будут безопасно удалены.

С `think()` вообще нет понятия начала или конца, вы просто каждый раз заново планируете вызов. Когда вам больше не нужно "процесситься" - вы просто не вызываете `set_next_think` либо `set_next_think_ctx`. Но если вам нужно остановить запланированный вызов - используйте `set_next_think(0)` либо `set_next_think_ctx(your_context_id, 0)` в зависимости от ситуации.

## Примечания

"Think" производительней классического "Process" за счёт нескольких вещей:

Сама функция `think()` (и те которые указаны в контекстах) вызывается только тогда - когда приходит указанное время. За счёт чего уменьшается количество вызовов и затраченное на это процессорное время. Например, если у нас есть объекты который надо процессить раз в минуту - с классическим способом `Process` будет всё равно вызываться раз в несколько тиков и уже внутри функции будет проверяться сколько времени прошло!

Все запланированные вызовы `think()` (и те которые указаны в контекстах) хранятся в разных листах в зависимости от времени ожидания. Например, те объекты которые вызываются каждую секунду или быстрее - в одном листе, объекты что вызываются раз в 10 минут - в другом. Таким образом нам не нужно проходить циклом по ВСЕМ объектам которые нужно процессить, а только по тем, которые имеют схожий интервал!

В дополнении к этому - подсистема расчитывает самое ближайшее время вызова для каждого такого листа, и, если самый ближайший вызов будет только через несколько минут - подсистема будет "спать" всё это время!
