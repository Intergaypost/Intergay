#define cycle_pause 15 //min 1
#define viewrange 9 //min 2

//HOSTILE NPC DEFINES CREDIT TO GUAP FOR THE FIRST ZOMBIE AI WRITEUP, AND TO GOON WHERE I'M SURE IT CAME FROM.
/mob/living/carbon/human
	var/list/path = new/list()
	var/frustration = 0
	var/atom/object_target
	var/reach_unable
	var/is_npc = 0
	var/mob/living/carbon/human/target
	var/list/path_target = new/list()
	var/list/path_idle = new/list()
	var/list/objects
	var/list/npc_attack_emote = list("yells!", "makes a scary noise!")
	var/list/npc_attack_sound = list()
	var/aggroed = TRUE

	proc/aggro_npc()
		if(!is_npc)
			return
		aggroed = TRUE

	// this is called when the target is within one tile
	// of distance from the zombie
	proc/attack_target(var/mob/living/carbon/human/target)
		if(!target)
			return
		if(target?.stat != CONSCIOUS && prob(70))
			return
		var/direct = get_dir(src, target)
		if ( (direct - 1) & direct)
			var/turf/Step_1
			var/turf/Step_2
			switch(direct)
				if(EAST|NORTH)
					Step_1 = get_step(src, NORTH)
					Step_2 = get_step(src, EAST)

				if(EAST|SOUTH)
					Step_1 = get_step(src, SOUTH)
					Step_2 = get_step(src, EAST)

				if(NORTH|WEST)
					Step_1 = get_step(src, NORTH)
					Step_2 = get_step(src, WEST)

				if(SOUTH|WEST)
					Step_1 = get_step(src, SOUTH)
					Step_2 = get_step(src, WEST)

			if(Step_1 && Step_2)
				var/check_1 = 1
				var/check_2 = 1

				check_1 = Adjacent(get_turf(src), Step_1, target) && Adjacent(Step_1, get_turf(target), target)

				check_2 = Adjacent(get_turf(src), Step_2, target) && Adjacent(Step_2, get_turf(target), target)

				if(check_1 || check_2)
					target.attack_hand(src)
					return
				else
					var/obj/structure/table/W = locate() in target.loc
					var/obj/structure/table/WW = locate() in src.loc
					if(W)
						W.do_climb(src)
						return 1
					else if(WW)
						WW.do_climb(src)
						return 1
					var/obj/structure/window/WWW = locate() in target.loc
					var/obj/structure/window/WWWW = locate() in src.loc
					if(W)
						if(src.r_hand || src.l_hand)
							if(r_hand)
								WWW.attackby(r_hand, src)
							else
								if(l_hand)
									WWW.attackby(l_hand, src)
						else
							WWW.attack_hand(src)
						return 1
					else if(WWWW)
						if(src.r_hand || src.l_hand)
							if(r_hand)
								WWWW.attackby(r_hand, src)
							else if(l_hand)
								WWWW.attackby(l_hand, src)
						else
							WWWW.attack_hand(src)
						return 1
		else if(Adjacent(src?.loc , target?.loc,target))
			if(src.r_hand || src.l_hand)
				if(r_hand && istype(r_hand, /obj/item))
					target.attackby(r_hand, src)
				else
					if(l_hand && istype(l_hand, /obj/item))
						target.attackby(l_hand, src)
			else
				target.attack_hand(src)
			//target.attack_hand(src)
			// sometimes push the enemy
			if(prob(80))
				if(prob(10))
					step(src,direct)
				else
					if(prob(80))
						zone_sel.selecting = pick("groin","l_leg","r_leg","r_foot","l_foot")
						target.kick_act(src)
/*
					else
						if(prob(80))
							zone_sel.selecting = pick("chest","vitals","r_hand","l_hand","groin")
							target.steal_act(src)
*/
			return 1
		else
			var/obj/structure/window/W = locate() in target.loc
			var/obj/structure/window/WW = locate() in src.loc
			if(W)
				if(src.r_hand || src.l_hand)
					if(r_hand)
						W.attackby(r_hand, src)
					else
						if(l_hand)
							W.attackby(l_hand, src)
				else
					W.attack_hand(src)
				return 1
			else if(WW)
				if(r_hand)
					WW.attackby(r_hand, src)
				else if(l_hand)
					WW.attackby(l_hand, src)
				else
					WW.attack_hand(src)
				return 1

	// main loop
	proc/process()
		set background = 1

		if (stat == 2)
			return 0
		if(weakened || paralysis || handcuffed || !canmove)
			return 1
		if(resting)
			mob_rest()
			return

		if(destroy_on_path())
			return 1

		combat_mode = 0
		if(target)
			// change the target if there is another human that is closer
			if(prob(30))
				target = null
			for (var/mob/living/carbon/C in orange(2,src.loc))
				if (C.stat == 2|| !can_see(src,C,viewrange))
					continue
				if (istype(C, /mob/living/carbon/human/raider))
					continue
				if(get_dist(src, target) >= get_dist(src, C) && prob(30))
					target = C
					break

			if(target?.stat == 2)
				target = null

			var/distance = get_dist(src, target)

			if(target in orange(viewrange,src))
				if(distance <= 1)
					if(attack_target())
						var/turf/T = get_step(src, target.dir)
						for(var/atom/A in T.contents)
							if(A.density)
								return 1
						if(!T.density)
							Move(T)
						return 1
				if(step_towards_3d(src,target))
					return 1
			else
				target = null
				return 1
		if(prob(20))
			step_rand(src)
		for(var/mob/living/carbon/human/H in orange(1, src.loc))
			if (!istype(H, /mob/living/carbon/human/raider))
				combat_mode = 1
				if(prob(75))
					var/face = 0
					if(grabbed_by.len)
						for(var/x = 1; x <= grabbed_by.len; x++)
							if(grabbed_by[x])
								face = 1
								break

					if(face)
						resist()
					if(!face)
						dir = get_dir(src, H)
						attack_target(H)
					target = H
				return 1
		return

	// destroy items on the path
	proc/destroy_on_path()
		// if we already have a target, use that
		if(object_target)
			if(!object_target.density)
				object_target = null
				frustration = 0
			else
				// we know the target has attack_hand
				// since we only use such objects as the target
				object_target:attack_hand(src)
				return 1

		// first, try to destroy airlocks and walls that are in the way
		if(locate(/obj/machinery/door/airlock) in get_step(src,src.dir))
			var/obj/machinery/door/airlock/D = locate() in get_step(src,src.dir)
			if(D)
				if(D.density && !(locate(/turf/space) in range(1,D)) )
					D.attack_hand(src)
					object_target = D
					return 1
		// before clawing through walls, try to find a direct path first
		if(frustration > 8 )
			if(istype(get_step(src,src.dir),/turf/simulated/wall))
				var/turf/simulated/wall/W = get_step(src,src.dir)
				if(W)
					if(W.density && !(locate(/turf/space) in range(1,W)))
						W.attack_hand(src)
						object_target = W
						return 1
		return 0

	death()
		..()
		target = null

/mob/living/carbon/human/monkey/punpun/New()
	..()
	name = "Pun Pun"
	real_name = name
	var/obj/item/clothing/C
	if(prob(50))
		C = new /obj/item/clothing/under/punpun(src)
		equip_to_appropriate_slot(C)
	else
		C = new /obj/item/clothing/under/punpants(src)
		C.attach_accessory(null, new/obj/item/clothing/accessory/toggleable/hawaii/random(src))
		equip_to_appropriate_slot(C)

/decl/hierarchy/outfit/blank_subject
	name = "Test Subject"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/helmet/facecover
	mask = /obj/item/clothing/mask/muzzle
	suit = /obj/item/clothing/suit/straight_jacket

/decl/hierarchy/outfit/blank_subject/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/under/color/white/C = locate() in H
	if(C)
		C.has_sensor  = SUIT_LOCKED_SENSORS
		C.sensor_mode = SUIT_SENSOR_OFF

/mob/living/carbon/human/blank/New(var/new_loc)
	..(new_loc, "Bio-Slave")

/mob/living/carbon/human/blank/Initialize()
	. = ..()
	var/number = "[pick(possible_changeling_IDs)]-[rand(1,30)]"
	fully_replace_character_name("Subject [number]")
	var/decl/hierarchy/outfit/outfit = outfit_by_type(/decl/hierarchy/outfit/blank_subject)
	outfit.equip(src)
	var/obj/item/clothing/head/helmet/facecover/F = locate() in src
	if(F)
		F.SetName("[F.name] ([number])")

/mob/living/carbon/human/blank/ssd_check()
	return FALSE

//Hostile NPCs.

/datum/species/human/raider/handle_npc(var/mob/living/carbon/human/H)//DON'T SPAWN TOO MANY OF THESE PLEASE!
	H.process()

/mob/living/carbon/human/raider/ssd_check()
	return FALSE

/mob/living/carbon/human/raider/New(var/new_loc)
	..()
	sleep(3)
	if(!mind)
		mind = new /datum/mind(src)
	// main loop
	spawn while(stat != 2 && is_npc)
		sleep(cycle_pause)
		src.process()
	var/number = "[pick(possible_changeling_IDs)]-[rand(1,30)]"
	fully_replace_character_name("raider [number]")
	zone_sel = new /obj/screen/zone_sel( null )
	zone_sel.selecting = pick("chest", "head")
	a_intent = I_HURT
	aggroed = FALSE
	var/decl/hierarchy/outfit/outfit = outfit_by_type(/decl/hierarchy/outfit/raider)
	outfit.equip(src)
	var/obj/item/clothing/head/helmet/facecover/F = locate() in src
	if(F)
		F.name = "[F.name] ([number])"
	is_npc = 1//Make sure their an NPC so they don't attack each other.
	hand = 0//Make sure one of their hands is active.
	put_in_hands(new /obj/item/weapon/material/sword/siegesword)//Give them a weapon.
	combat_mode = 1//Put them in combat mode.
	generate_stats(STAT_DX)

/decl/hierarchy/outfit/raider
	name = "Raider"
	uniform = /obj/item/clothing/under/merc
	shoes = /obj/item/clothing/shoes/dutyboots
	head = /obj/item/clothing/head/helmet/siege
	mask = /obj/item/clothing/mask/gas/newsecurity
	suit = /obj/item/clothing/suit/armor/breastplate
	gloves = /obj/item/clothing/gloves/combat/gloves