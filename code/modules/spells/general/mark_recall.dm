/datum/spell/mark_recall
	name = "Mark and Recall"
	desc = "This spell was created so wizards could get home from the bar without driving. Does not require wizard garb."
	feedback = "MK"
	school = "conjuration"
	charge_max = 600 //1 minutes for how OP this shit is (apparently not as op as I thought)
	spell_flags = Z2NOCAST
	invocation = "Re-Alki R'natha."
	invocation_type = SPI_WHISPER
	cooldown_min = 300
	need_target = FALSE

	smoke_amt = 1
	smoke_spread = 5

	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 1)

	cast_sound = 'sound/effects/teleport.ogg'
	icon_state = "wiz_mark"
	var/mark = null

/datum/spell/mark_recall/choose_targets()
	if(!mark)
		return list("magical fairy dust") //because why not
	else
		return list(mark)

/datum/spell/mark_recall/cast(list/targets, mob/user)
	if(istype(user.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/cell = user.loc
		cell.go_out()
	if(!targets.len)
		return FALSE
	var/target = targets[1]
	if(istext(target))
		mark = new /obj/effect/decal/cleanable/wizard_mark(get_turf(user),src)
		return TRUE
	if(!istype(target,/obj)) //something went wrong
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	user.forceMove(T)
	..()

/datum/spell/mark_recall/empower_spell()
	if(!..())
		return FALSE

	spell_flags = STATALLOWED

	return "You no longer have to be conscious to activate this spell."

/obj/effect/decal/cleanable/wizard_mark
	name = "\improper Mark of the Wizard"
	desc = "A strange rune said to be made by wizards. Or its just some shmuck playing with crayons again."
	icon = 'icons/obj/rune.dmi'
	icon_state = "wizard_mark"

	anchored = TRUE
	unacidable = TRUE
	layer = TURF_LAYER

	var/datum/spell/mark_recall/spell

/obj/effect/decal/cleanable/wizard_mark/New(newloc,mrspell)
	..()
	spell = mrspell

/obj/effect/decal/cleanable/wizard_mark/Destroy()
	spell.mark = null //dereference pls.
	spell = null
	return ..()

/obj/effect/decal/cleanable/wizard_mark/attack_hand(mob/user)
	if(user == spell.holder)
		user.visible_message("\The [user] mutters an incantation and \the [src] disappears!")
		qdel(src)
	..()

/obj/effect/decal/cleanable/wizard_mark/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/nullrod) || istype(I, /obj/item/spellbook))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		src.visible_message("\The [src] fades away!")
		qdel(src)
		return
	..()
