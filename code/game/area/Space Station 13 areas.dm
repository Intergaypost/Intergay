/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/



/area
	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = BASE_AREA_LAYER
	luminosity = 0
	mouse_opacity = 0
	var/lightswitch = 1

	var/eject = null

	var/debug = 0
	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1 // Status
	var/power_light = 1
	var/power_environ = 1
	var/used_equip = 0  // Continuous drain; don't mess with these directly.
	var/used_light = 0
	var/used_environ = 0
	var/oneoff_equip   = 0 //Used once and cleared each tick.
	var/oneoff_light   = 0
	var/oneoff_environ = 0

	var/has_gravity = 1
	var/obj/machinery/power/apc/apc = null
	var/no_air = null
//	var/list/lights				// list of all lights on this area
	var/list/all_doors = null		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0
	var/list/ambience = list('sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg', 'sound/ambience/1_ship_1.ogg', 'sound/ambience/1_ship_2.ogg', 'sound/ambience/1_ship_3.ogg', 'sound/ambience/1_ship_4.ogg', 'sound/ambience/1_ship_5.ogg', 'sound/ambience/1_ship_6.ogg', 'sound/ambience/1_ship_7.ogg', 'sound/ambience/1_ship_8.ogg', 'sound/ambience/tstation.ogg', 'sound/ambience/ambiencehuh1.ogg', 'sound/ambience/ambiencehuh2.ogg', 'sound/ambience/ambiencehuh3.ogg', 'sound/ambience/ambiencehuh4.ogg', 'sound/ambience/ambiencehuh5.ogg')
	var/list/forced_ambience = null
	var/sound_env = STANDARD_STATION
	var/turf/base_turf //The base turf type of the area, which can be used to override the z-level's base turf

/*-----------------------------------------------------------------------------*/

/////////
//SPACE//
/////////

/area/space
	name = "Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	dynamic_lighting = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	has_gravity = 0
	area_flags = AREA_FLAG_EXTERNAL
	ambience = list('sound/ambience/ambispace.ogg')
	forced_ambience = list('sound/ambience/hostile_space.ogg')

/area/space/update_icon()
	return

area/space/atmosalert()
	return

/area/space/fire_alert()
	return

/area/space/fire_reset()
	return

/area/space/readyalert()
	return

/area/space/partyalert()
	return

//////////////////////
//AREAS USED BY CODE//
//////////////////////
/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = 1

/area/centcom/holding
	name = "Holding Facility"

/area/chapel
	name = "Chapel"
	icon_state = "chapel"

/area/centcom/specops
	name = "Centcom Special Ops"

/area/hallway
	name = "hallway"

/area/medical
	name = "Medical"
	forced_ambience = list('sound/ambience/arrivals.ogg')

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/virologyaccess
	name = "Virology Access"
	icon_state = "virology"

/area/security
	name = "Security"
	icon_state = "brig"
	forced_ambience = list('sound/ambience/ops1.ogg')

/area/security/brig
	name = "Security - Brig"
	icon_state = "brig"
	forced_ambience = list('sound/ambience/ops1.ogg')

/area/security/prison
	name = "Security - Prison Wing"
	icon_state = "sec_prison"
	forced_ambience = list('sound/ambience/ops1.ogg')

/area/maintenance
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = TUNNEL_ENCLOSED
	turf_initializer = /decl/turf_initializer/maintenance
	forced_ambience = list('sound/ambience/FAC.ogg')

/area/rnd
	name = "RD"
	forced_ambience = list('sound/ambience/computer_amb1.ogg')

/area/rnd/xenobiology
	name = "Xenobiology Lab"
	icon_state = "xeno_lab"

/area/rnd/xenobiology/xenoflora
	name = "Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/rnd/xenobiology/xenoflora_storage
	name = "Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/shuttle/escape/centcom
	name = "Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/specops/centcom
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/mothership
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	icon_state = "shuttlered2"

/area/skipjack_station/start
	name = "Skipjack"
	icon_state = "yellow"

/area/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/syndicate_mothership/elite_squad
	name = "Elite Mercenary Squad"
	icon_state = "syndie-elite"

////////////
//SHUTTLES//
////////////
//shuttles only need starting area, movement is handled by landmarks
//All shuttles should now be under shuttle since we have smooth-wall code.

/area/shuttle
	requires_power = 0
	sound_env = SMALL_ENCLOSED

/*
* Special Areas
*/
/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 0

/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0
	var/sound/mysound = null

/area/beach/New()
	..()
	var/sound/S = new/sound()
	mysound = S
	S.file = 'sound/ambience/shore.ogg'
	S.repeat = 1
	S.wait = 0
	S.channel = 123
	S.volume = 100
	S.priority = 255
	S.status = SOUND_UPDATE
	process()

/area/beach/Entered(atom/movable/Obj,atom/OldLoc)
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_UPDATE
			sound_to(M, mysound)

/area/beach/Exited(atom/movable/Obj)
	. = ..()
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_PAUSED | SOUND_UPDATE
			sound_to(M, mysound)

/area/beach/proc/process()
	set background = 1

	var/sound/S = null
	var/sound_delay = 0
	if(prob(25))
		S = sound(file=pick('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag3.ogg'), volume=100)
		sound_delay = rand(0, 50)

	for(var/mob/living/carbon/human/H in src)
		if(H.client)
			mysound.status = SOUND_UPDATE
			to_chat(H, mysound)
			if(S)
				spawn(sound_delay)
					sound_to(H, S)

	spawn(60) .()


/area/thunderfield
	name = "Thunderfield"
	icon_state = "yellow"