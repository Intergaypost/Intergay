/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = list(TECH_MATERIAL = 2, TECH_COMBAT = 1)
	var/banglet = 0

/obj/item/weapon/grenade/flashbang/detonate()
	..()
	for(var/obj/structure/closet/L in hear(7, get_turf(src)))
		if(locate(/mob/living/carbon/, L))
			for(var/mob/living/carbon/M in L)
				bang(get_turf(src), M)


	for(var/mob/living/carbon/M in hear(7, get_turf(src)))
		bang(get_turf(src), M)

	for(var/obj/effect/blob/B in hear(8,get_turf(src)))//Blob damage here
		var/damage = round(30/(get_dist(B,get_turf(src))+1))
		B.health -= damage
		B.update_icon()

	new/obj/effect/sparks(loc)
	new/obj/effect/effect/smoke/illumination(src.loc, 5, range=30, power=30, color="#ffffff")
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/proc/bang(var/turf/T , var/mob/living/carbon/M)
	to_chat(M, "<span class='danger'>BANG!</span>")
	playsound(src, 'sound/effects/bang.ogg', 100)

	//Checking for protections
	var/eye_safety = 0
	var/ear_safety = 0
	if(iscarbon(M))
		eye_safety = M.eyecheck()
		if(ishuman(M))
			if(HULK in M.mutations)
				ear_safety += 1
			var/mob/living/carbon/human/H = M
			if(istype(H.head, /obj/item/clothing/head/helmet))
				ear_safety += 1

	//Flashing everyone
	M.flash_eyes(FLASH_PROTECTION_MODERATE)
	if(eye_safety < FLASH_PROTECTION_MODERATE)
		M.Stun(2)
		M.confused += 5

	//Now applying sound
	if(ear_safety)
		if(ear_safety < 2 && get_dist(M, T) <= 2)
			M.Stun(1)
			M.confused += 3

	else if(get_dist(M, T) <= 2)
		M.Stun(3)
		M.confused += 8
		M.ear_damage += rand(0, 5)
		M.ear_deaf = max(M.ear_deaf,15)

	else if(get_dist(M, T) <= 5)
		M.Stun(2)
		M.confused += 5
		M.ear_damage += rand(0, 3)
		M.ear_deaf = max(M.ear_deaf,10)

	else
		M.Stun(1)
		M.confused += 3
		M.ear_damage += rand(0, 1)
		M.ear_deaf = max(M.ear_deaf,5)

	//This really should be in mob not every check
	switch(M.ear_damage)
		if(1 to 14)
			to_chat(M, "<span class='danger'>Your ears start to ring!</span>")
		if(15 to INFINITY)
			to_chat(M, "<span class='danger'>Your ears start to ring badly!</span>")

	//if(!ear_safety)
		//sound_to(M, 'sound/weapons/flash_ring.ogg')

/obj/item/weapon/grenade/flashbang/Destroy()
	SSmove_manager.stop_looping(src)
	return ..()


/obj/item/weapon/grenade/flashbang/clusterbang//Created by Polymorph, fixed by Sieve
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"

/obj/item/weapon/grenade/flashbang/clusterbang/detonate()
	var/numspawned = rand(4,8)
	var/again = 0
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)//Launches flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	for(,again > 0, again--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/clusterbang/segment(src.loc)//Creates a 'segment' that launches a few more flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/flashbang/clusterbang/segment/New()//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = 1
	banglet = 1
	var/stepdist = rand(1,4)//How far to step
	var/temploc = src.loc//Saves the current location to know where to step away from
	SSmove_manager.move_away(src, temploc, stepdist, delay = 2, timeout = stepdist * 2)
	var/dettime = rand(15,60)
	spawn(dettime)
		detonate()
	..()

/obj/item/weapon/grenade/flashbang/clusterbang/segment/detonate()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)
	return

/obj/item/weapon/grenade/flashbang/cluster/New()//Same concept as the segments, so that all of the parts don't become reliant on the clusterbang
	spawn(0)
		icon_state = "flashbang_active"
		active = 1
		banglet = 1
		var/stepdist = rand(1,3)
		var/temploc = src.loc
		SSmove_manager.move_away(src, temploc, stepdist, delay = 2, timeout = stepdist * 2)
		var/dettime = rand(15,60)
		spawn(dettime)
		detonate()
	..()

