/***********
* Implants *
***********/
/datum/uplink_item/item/implants
	category = /datum/uplink_category/implants

/datum/uplink_item/item/implants/imp_freedom
	name = "Freedom Implant"
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/imp_freedom

/datum/uplink_item/item/implants/imp_compress
	name = "Compressed Matter Implant"
	item_cost = 3
	path = /obj/item/storage/box/syndie_kit/imp_compress

/datum/uplink_item/item/implants/imp_explosive
	name = "Explosive Implant (DANGER!)"
	item_cost = 6
	path = /obj/item/storage/box/syndie_kit/imp_explosive

/datum/uplink_item/item/implants/imp_uplink
	name = "Uplink Implant"
	path = /obj/item/storage/box/syndie_kit/imp_uplink

/datum/uplink_item/item/implants/imp_uplink/New()
	..()
	item_cost = round(DEFAULT_TELECRYSTAL_AMOUNT / 2)
	desc = "Contains [IMPLANT_TELECRYSTAL_AMOUNT(DEFAULT_TELECRYSTAL_AMOUNT)] Telecrystal\s"

/datum/uplink_item/item/implants/imp_imprinting
	name = "Neural Imprinting Implant"
	desc = "Use on someone who is under influence of Mindbreaker to give them laws-like set of instructions. Kit comes with a dose of mindbreaker."
	item_cost = 4
	path = /obj/item/storage/box/syndie_kit/imp_imprinting

/datum/uplink_item/item/implants/adrenalin
	name = "Adrenalin Implant"
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/adrenalin

/datum/uplink_item/item/implants/spy
	name = "Spy Implant"
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/spy_implant
