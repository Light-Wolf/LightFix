/mob/living/simple_animal/hostile/russian
	name = "russian"
	desc = "For the Motherland!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	can_escape = 1
	attacktext = "punched"
	a_intent = I_HURT
	bodyparts = /decl/simple_animal_bodyparts/humanoid
	var/corpse = /obj/effect/landmark/corpse/russian
	var/weapon1 = /obj/item/material/knife
	unsuitable_atoms_damage = 15
	faction = "russian"
	status_flags = CANPUSH


/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	corpse = /obj/effect/landmark/corpse/russian/ranged
	weapon1 = /obj/item/gun/projectile/revolver/mateba
	ranged = 1
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/effects/weapons/gun/gunshot2.ogg'
	casingtype = /obj/item/ammo_casing/a50


/mob/living/simple_animal/hostile/russian/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	qdel(src)
	return