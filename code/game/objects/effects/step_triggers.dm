/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = 0
	var/stopper = 1 // stops throwers
	invisibility = 101 // nope cant see this shit
	anchored = 1

/obj/effect/step_trigger/proc/Trigger(var/atom/movable/A)
	return 0

/obj/effect/step_trigger/Crossed(H as mob|obj)
	..()
	if(!H)
		return
	if(isobserver(H) && !(isghost(H) && affect_ghosts))
		return
	Trigger(H)



/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/facedir = 0 // if 1: atom faces the direction of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

/obj/effect/step_trigger/thrower/Trigger(var/atom/movable/AM)
	if(!AM || !istype(AM) || !AM.simulated)
		return
	for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
		if(AM in T.affecting)
			return

	if(ismob(AM))
		var/mob/M = AM
		if(immobilize)
			M.canmove = 0

	affecting[AM] = AM.dir
	var/datum/move_loop/loop = SSmove_manager.move(AM, direction, speed, tiles ? tiles * speed : INFINITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/set_to_normal)

/obj/effect/step_trigger/thrower/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	affecting[being_moved] = being_moved.dir

/obj/effect/step_trigger/thrower/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	if(!facedir)
		being_moved.set_dir(affecting[being_moved])
	if(being_moved.z != z)
		qdel(source)
		return
	if(!nostop)
		for(var/obj/effect/step_trigger/T in get_turf(being_moved))
			if(T.stopper && T != src)
				qdel(source)
				return
	else
		for(var/obj/effect/step_trigger/teleporter/T in get_turf(being_moved))
			if(T.stopper)
				qdel(source)
				return

/obj/effect/step_trigger/thrower/proc/set_to_normal(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	affecting -= being_moved
	if(ismob(being_moved))
		var/mob/M = being_moved
		if(immobilize)
			M.canmove = 1


/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

	Trigger(var/atom/movable/A)
		if(teleport_x && teleport_y && teleport_z)

			A.x = teleport_x
			A.y = teleport_y
			A.z = teleport_z

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	opacity = 1
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

/obj/effect/step_trigger/teleporter/random/Trigger(var/atom/movable/A)
	var/turf/T = locate(rand(teleport_x, teleport_x_offset), rand(teleport_y, teleport_y_offset), rand(teleport_z, teleport_z_offset))
	if(T)
		A.forceMove(T)
