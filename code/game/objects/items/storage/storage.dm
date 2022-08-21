// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = ITEM_SIZE_NORMAL
	var/list/can_hold = new /list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new /list() //List of objects which this item can't store (in effect only if can_hold isn't set)

	var/max_w_class = ITEM_SIZE_SMALL //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_storage_space = null //Total storage cost of items this can hold. Will be autoset based on storage_slots if left null.
	var/storage_slots = null //The number of storage slots in this container.
	var/list/override_w_class // List of items that can bypass the max_w_class restriction

	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/use_sound = SFX_SEARCH_CASE	//sound played when used. null for no sound.

	//initializes the contents of the storage with some items based on an assoc list. The assoc key must be an item path,
	//the assoc value can either be the quantity, or a list whose first value is the quantity and the rest are args.
	var/list/startswith
	var/datum/storage_ui/storage_ui = /datum/storage_ui/default

/obj/item/storage/Destroy()
	QDEL_NULL(storage_ui)
	. = ..()

/obj/item/storage/MouseDrop(obj/over_object as obj)
	if(!canremove)
		return

	if((ishuman(usr) || isrobot(usr) || issmall(usr)) && !usr.incapacitated())
		if(over_object == usr && Adjacent(usr)) // this must come before the screen objects only block
			src.add_fingerprint(usr)
			src.open(usr)
			return TRUE

		if(!(istype(over_object, /obj/screen)))
			return ..()

		//makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
		if(!usr.contains(src))
			return

		src.add_fingerprint(usr)
		if(usr.unEquip(src))
			switch(over_object.name)
				if(BP_R_HAND)
					usr.put_in_r_hand(src)
				if(BP_L_HAND)
					usr.put_in_l_hand(src)

/obj/item/storage/AltClick(mob/usr)
	if(!canremove)
		return

	if((ishuman(usr) || isrobot(usr) || issmall(usr)) && !usr.incapacitated() && Adjacent(usr))
		add_fingerprint(usr)
		open(usr)
		return TRUE

/obj/item/storage/proc/return_inv()
	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/storage))
			L += G.gift:return_inv()
	return L

/obj/item/storage/proc/show_to(mob/user)
	if(storage_ui)
		storage_ui.show_to(user)

/obj/item/storage/proc/hide_from(mob/user)
	if(storage_ui)
		storage_ui.hide_from(user)

/obj/item/storage/proc/open(mob/user)
	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	if(isrobot(user) && user.hud_used)
		var/mob/living/silicon/robot/robot = user
		if(robot.shown_robot_modules) //The robot's inventory is open, need to close it first.
			robot.hud_used.toggle_show_robot_modules()

	prepare_ui()
	if(storage_ui) // I guess we can afford performing double checks for such procs. Better this than hundreds of runtimes.
		storage_ui.on_open(user)
		storage_ui.show_to(user)

/obj/item/storage/proc/prepare_ui()
	if(storage_ui)
		storage_ui.prepare_ui()

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	if(storage_ui)
		storage_ui.after_close(user)

	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)

/obj/item/storage/proc/close_all()
	if(storage_ui)
		storage_ui.close_all()

/obj/item/storage/proc/storage_space_used()
	. = 0
	for(var/obj/item/I in contents)
		. += I.get_storage_cost()

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, mob/user, stop_messages = 0)
	if(!istype(W))
		return //Not an item

	if(user && user.isEquipped(W) && !user.canUnEquip(W))
		return 0

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(storage_slots != null && contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] is full, make some space.</span>")
		return 0 //Storage item is full

	if(W.anchored)
		return 0

	if(length(can_hold))
		if(!is_type_in_list(W, can_hold))
			if(!stop_messages && ! istype(W, /obj/item/hand_labeler))
				to_chat(user, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
			return 0
		var/max_instances = can_hold[W.type]
		if(max_instances && instances_of_type_in_list(W, contents) >= max_instances)
			if(!stop_messages && !istype(W, /obj/item/hand_labeler))
				to_chat(user, "<span class='notice'>\The [src] has no more space specifically for \the [W].</span>")
			return 0

	//If attempting to lable the storage item, silently fail to allow it
	if(istype(W, /obj/item/hand_labeler) || istype(W, /obj/item/forensics) && user.a_intent != I_HELP)
		return FALSE

	// Don't allow insertion of unsafed compressed matter implants
	// Since they are sucking something up now, their afterattack will delete the storage
	if(istype(W, /obj/item/implanter/compressed))
		var/obj/item/implanter/compressed/impr = W
		if(!impr.safe)
			stop_messages = 1
			return 0

	if(cant_hold.len && is_type_in_list(W, cant_hold))
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
		return 0

	if(max_w_class != null && W.w_class > max_w_class && !(override_w_class?.len && is_type_in_list(W, override_w_class)))
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [W] is too big for this [src.name].</span>")
		return 0

	var/total_storage_space = W.get_storage_cost()
	if(total_storage_space == ITEM_SIZE_NO_CONTAINER)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [W] cannot be placed in [src].</span>")
		return 0

	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] is too full, make some space.</span>")
		return 0

	return 1

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = 0, NoUpdate = 0)
	if(!istype(W))
		return 0
	if(ismob(W.loc))
		var/mob/M = W.loc
		if(!M.unEquip(W))
			return
	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		add_fingerprint(usr)

		if(!prevent_warning)
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, "<span class='notice'>You put \the [W] into [src].</span>")
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is... TODO replace with distance check
					M.show_message("<span class='notice'>\The [usr] puts [W] into [src].</span>")
				else if (W && W.w_class >= ITEM_SIZE_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>\The [usr] puts [W] into [src].</span>")

		if(!NoUpdate)
			update_ui_after_item_insertion()

	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)

	update_icon()
	return 1

/obj/item/storage/proc/update_ui_after_item_insertion()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_insertion(usr)

/obj/item/storage/proc/update_ui_after_item_removal()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_post_remove(usr)

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location, NoUpdate = 0)
	if(!istype(W))
		return 0
	new_location = new_location || get_turf(src)

	if(storage_ui)
		storage_ui.on_pre_remove(usr, W)

	if(ismob(loc))
		W.dropped(usr)
	if(ismob(new_location))
		W.hud_layerise()
	else
		W.reset_plane_and_layer()
	W.forceMove(new_location)

	if(usr && !NoUpdate)
		update_ui_after_item_removal()
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	if(!NoUpdate)
		update_icon()
	return 1

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_pre_deletion(obj/item/W)
	if(storage_ui)
		storage_ui.on_pre_remove(usr, W)

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_post_deletion()
	update_ui_after_item_removal()
	update_icon()

//Run once after using remove_from_storage with NoUpdate = 1
/obj/item/storage/proc/finish_bulk_removal()
	update_ui_after_item_removal()
	update_icon()

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/W, mob/user)
	. = ..()

	if(.)
		return

	if(isrobot(user) && W == user.get_active_hand())
		return //Robots can't store their modules.

	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LP = W
		var/amt_inserted = 0
		var/turf/T = get_turf(user)
		for(var/obj/item/light/L in src.contents)
			if(L.status == 0)
				if(LP.uses < LP.max_uses)
					LP.AddUses(1)
					amt_inserted++
					remove_from_storage(L, T)
					qdel(L)
		if(amt_inserted)
			to_chat(user, "You inserted [amt_inserted] light\s into \the [LP.name]. You have [LP.uses] light\s remaining.")
			return

	if(!can_be_inserted(W, user))
		return

	if(istype(W, /obj/item/tray))
		var/obj/item/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, "<span class='warning'>The tray won't fit in [src].</span>")
				return
			else
				if(user.unEquip(W))
					to_chat(user, "<span class='warning'>God damnit!</span>")
	W.add_fingerprint(user)
	return handle_item_insertion(W)

/obj/item/storage/allow_drop()
	return TRUE

/obj/item/storage/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return

	if(loc == user)
		open(user)
	else
		..()
		if(storage_ui)
			storage_ui.on_hand_attack(user)
	add_fingerprint(user)
	return

/obj/item/storage/proc/gather_all(turf/T, mob/user)
	var/success = 0
	var/failure = 0

	for(var/obj/item/I in T)
		if(!can_be_inserted(I, user, 0))	// Note can_be_inserted still makes noise when the answer is no
			failure = 1
			continue
		success = 1
		handle_item_insertion(I, 1, 1) // First 1 is no messages, second 1 is no ui updates
	if(success && !failure)
		to_chat(user, "<span class='notice'>You put everything into \the [src].</span>")
		if (src.use_sound)
			playsound(src.loc, src.use_sound, 50, 1, -5)
		update_ui_after_item_insertion()
	else if(success)
		to_chat(user, "<span class='notice'>You put some things into \the [src].</span>")
		if (src.use_sound)
			playsound(src.loc, src.use_sound, 50, 1, -5)
		update_ui_after_item_insertion()
	else
		to_chat(user, "<span class='notice'>You fail to pick anything up with \the [src].</span>")

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "\The [src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "\The [src] now picks up one item at a time.")

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T, 1)
	finish_bulk_removal()

/obj/item/storage/Initialize()
	. = ..()
	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	if(isnull(max_storage_space) && !isnull(storage_slots))
		max_storage_space = storage_slots * base_storage_cost(max_w_class)

	storage_ui = new storage_ui(src)
	prepare_ui()

	if(startswith)
		for(var/item_path in startswith)
			var/list/data = startswith[item_path]
			if(islist(data))
				var/qty = data[1]
				var/list/argsl = data.Copy()
				argsl[1] = src
				for(var/i in 1 to qty)
					new item_path(arglist(argsl))
			else
				for(var/i in 1 to (isnull(data)? 1 : data))
					new item_path(src)
		update_icon()

/obj/item/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/storage/verb/quick_empty))
			quick_empty()
			return 1

/obj/item/storage/proc/make_exact_fit()
	storage_slots = contents.len

	can_hold.Cut()
	max_w_class = 0
	max_storage_space = 0
	for(var/obj/item/I in src)
		can_hold[I.type]++
		max_w_class = max(I.w_class, max_w_class)
		max_storage_space += I.get_storage_cost()

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/proc/get_storage_cost() //If you want to prevent stuff above a certain w_class from being stored, use max_w_class
	return base_storage_cost(w_class)