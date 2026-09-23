//Old god spells.  Defines rrequirements and effect if the spell is cast
// REQUIRMENTS: All spells require specific items in a specific location on a 3x3 grid.  there are specified as:
// NORTHWEST | NORTH | NORTHEAST
// WEST      | CENTER | EAST
// SOUTHWEST | SOUTH | SOUTHEAST

// spell_effect: All spells have an effect when they are activated and the requirments are met.  Define anything you want the spell to do here.

// THESE ARE THE ONLY THINGS YOU NEED TO DO TO CREATE A NEW OLD GOD SPELL.
// THERE ARE SOME THINGS NOT TO DO:
// 		DO NOT OVERRIDE /obj/old_god_shrine/hear_talk


/datum/old_god_spell
	var/name = "old god spell"
	var/list/requirments = list()
	var/old_god = LEGAL_RELIGION
	var/phrase = "Test Phrase"

/datum/old_god_spell/New()
	var/datum/religion/rel = GLOB.all_religions[old_god]
	if(rel)
		phrase = rel.generate_random_phrase()
	..()

/datum/old_god_spell/proc/spell_effect(var/mob/living/user)
	to_world("Something is fucked up, you should not be seeing this. It's from old gods spell code, go tell a coder.")

	//Helper to make spells involving paper easier TODO: same thing for blood/limbs/organs
/datum/old_god_spell/proc/get_player_from_paper(var/obj/item/weapon/paper/target_paper)
	for(var/mob/player in GLOB.player_list)
		if(findtext(target_paper.info, player.name))
			return player

	//Consumes the spell componenets before casting.  Some spells may want to leave some items behind, and it's more efficient if they specify as well
/datum/old_god_spell/proc/spell_consume(var/list/spell_components)
	for(var/direction in spell_components)
		qdel(spell_components[direction])

/* // Demonstration of working order.
/datum/old_god_spell/smoke_example
	name = "Simple puff of smoke to demonstrate"
	requirments = list("NORTH" = /obj/item/weapon/paper)
	old_god = "None"

	spell_effect(var/mob/living/user, var/list/spell_components)
		var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
		smoke.set_up(5, 0, user.loc)
		smoke.attach(user)
		smoke.start()
*/

//Yeah this is fucking stupid, but I can't make associatve lists like list(NORTH=1) because fucking byond, so we need to do list("NORTH"=1) and pass through here.
proc/DIRECTION_TO_VAL(var/direction)
	switch(direction)
		if("NORTH") return NORTH
		if("NORTHEAST") return NORTHEAST
		if("EAST") return EAST
		if("SOUTHEAST") return SOUTHEAST
		if("SOUTH") return SOUTH
		if("SOUTHWEST") return SOUTHWEST
		if("WEST") return WEST
		if("NORTHWEST") return NORTHWEST
	return null
