/obj/item/device/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	zoomdevicename = "eyepieces"
	icon_state = "binoculars"

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	mod_weight = 0.6
	mod_reach = 0.5
	mod_handy = 0.85
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15


/obj/item/device/binoculars/attack_self(mob/user)
	if(zoom)
		unzoom(user)
	else
		zoom(user)
