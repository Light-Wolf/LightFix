# Сигналы, компоненты и элементы

## Сигналы

Сигналы - концепт, позволяющий реализовать парадигму реактивного программирования. Они позволяют реагировать на разные события из других частей кода, при этом объект вызывающий событие может ничего не знать про объектов следящих за его событиями.

В билде сигналы почти точная копия сигналов с `/TG/station`.

### Использование

Основным API для работы с сигналами являются:

- Макросы `SEND_SIGNAL`, `SEND_GLOBAL_SIGNAL`:

```dm
SEND_SIGNAL(target, sigtype, arguments...)
SEND_GLOBAL_SIGNAL(sigtype, arguments...)
```

Они используются для отправки сигналов.

`target` - куда отправить сигнал, все слушатели `target` получат этот сигнал. Если сигнал происходит с текущим объектом - вместо `target` соответственно указываем `src`.

`sigtype` - некая строка, название сигнала.

`arguments...` - аргументы которые передаёт источник сигнала.

`SEND_GLOBAL_SIGNAL` идентична макросу выше, за исключением того что нельзя указать получателя - он уже указан и в качестве него испольуется подсистема `SSelements`.

- Функции `register_signal`, `register_global_signal`:

```dm
/datum/proc/register_signal(datum/target, sig_type_or_types, proctype, override = FALSE)
/datum/proc/register_global_signal(sig_type_or_types, proctype, override = FALSE)
```

Эти функции используются для подписывания на сигналы.

`target` - откуда ждать сигнала.

`sig_type_or_types` - название сигнала или лист названии.

`proctype` - путь функции которая будет вызвана при получении сигнала. Например: `/datum/click_handler/proc/OnMobLogout`

`register_global_signal` также как и макрос отличается от соседней функции только уже указанным получателем.

`override` - если FALSE (по-умолчанию) - сообщает об ошибке при повторной регистрации одного и того же сигнала.

- Функции `unregister_signal`, `unregister_global_signal`:

```dm
/datum/proc/unregister_signal(datum/target, sig_type_or_types)
/datum/proc/unregister_global_signal(sig_type_or_types)
```

Эти функции отписывают все функции которые должны быть вызваны при получении определённого сигнала.

`target` - источник сигнала, от которого необходимо отписать некоторые сигналы.

`sig_type_or_types` - типы сигнала или сигналов, которые необходимо прекратить слушать.

### Применение

У нас есть некоторая консоль `/obj/status_console` которая следит за показателем здоровья каждого члена экипажа и при падении здоровья ниже 20 - должна проигрывать звук.

Самым наивным способом можно добавить проверку на количество здоровья в функцию `Life` (если она у нас ещё есть) или при получении урона, найти список всех консолей и проиграть им звук:

```dm
/mob/on_low_health()
    for(var/obj/status_console/C in world)
        playsound(C, ...)
```

Есть второй способ с использованием подсистем (если они у нас есть) - каждое N количество тиков проверять здоровье всех членов экипажа и также проигрывать всем консолям звук:

```dm
for(var/mob/M in mob_list)
    if(M.health < 20)
        for(var/obj/status_console/C in world)
            playsound(C, ...)
```

При таком способе страдает производительность - приходится постоянно проверять всех мобов и существует неточность - между теми тиками когда мы проверяем всех мобов их здоровье может упасть ниже установленной нами границой и затем даже подняться. Это приводит к тому что иногда мы может не успеть обнаружить падение здоровья или найти с опозданием.

Есть третий способ с сигналами. Для начала нужно создать строку которая будет использована в качестве идентификатора нашего сигнала:

```dm
#define SIGNAL_LOW_HEALTH "low_health"
```

Затем в функцию `Life`, или иную другую, мобов добавить проверку на здоровье и вызов сигнала:

```dm
if(health < 20)
    SEND_GLOBAL_SIGNAL(SIGNAL_LOW_HEALTH, src)
    SEND_SIGNAL(src, SIGNAL_LOW_HEALTH, src)
```

Здесь мы послали в себя и глобально сигнал `SIGNAL_LOW_HEALTH` и аргументом также передаём себя.

В нашем случае глобальный сигнал будет оправданым - нашей консоли нужно знать обо всех раненых мобов (можно добавить проверку на его наличие в списке экипажа).

Если вы отправляете глобальный сигнал - также важно добавить и его локальную версию (`target` = `src`), иногда может будет удобнее слушать сигнал только конкретного объекта, а не всех.

Например: у нас есть сигнал "!death", который срабатывает при смерти моба. Он передаётся как глобально так и локально. Второй случай нам нужен для меча культистов - после удара по мобу, если он умрёт в течении нескольких секунд - необходимо выполнить некоторые действие. В этом случае при ударе по мобу мы должны слушать сигнал о смерти конкретного моба а не всех!

Мы добавили `SEND_SIGNAL` нашим мобам когда у них меньше 20 здоровья - теперь нужно добавить реакцию на этот сигнал.

Это можно сделать по-разному, в нашем случае можно начать слушать сигнал с самого создания консоли:

```dm
/obj/status_console/Initialize()
    ..()

    register_global_signal(SIGNAL_LOW_HEALTH, /obj/status_console/proc/on_low_health)

/obj/status_console/Destroy()
    unregister_global_signal(SIGNAL_LOW_HEALTH)

    ..()

/obj/status_console/proc/on_low_health(mob/M)
    playsound(src, ...)
```

Здесь мы создали функцию `on_low_health(mob/M)` (внимание на аргументы - `mob/M` - это тот объект который передаётся в `SEND_SIGNAL` после названия сигнала, в нашем случае здесь только один аргумент). Также мы подписались на глобальное событие `SIGNAL_LOW_HEALTH` и сообщили что обрабатывать этот сигнал будет функция `/obj/status_console/proc/on_low_health`.

Теперь в любой момент когда у любого моба здоровье будет меньше 20 - будет вызвана функция `/obj/status_console/proc/on_low_health`.

И не забывайте производить отписку от всех подписанных сигналов! В данном случае это можно сделать в `Destroy`.

## Дополнительные ссылки

- https://hackmd.io/@tgstation/SignalsComponentsElements