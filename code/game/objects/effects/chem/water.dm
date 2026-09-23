/obj/effect/effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	mouse_opacity = 0
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE

/obj/effect/effect/water/New(loc)
	..()
	spawn(150) // In case whatever made it forgets to delete it
		if(src)
			qdel(src)

/obj/effect/effect/water/proc/set_color() // Call it after you move reagents to it
	icon += reagents.get_color()

/obj/effect/effect/water/proc/set_up(var/turf/target, var/step_count = 5, var/delay = 5)
	if(!target)
		return
	var/datum/move_loop/loop = SSmove_manager.move_towards_legacy(src, target, delay, timeout = step_count * delay, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/on_water_step, step_count)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/on_water_loop_end)

/obj/effect/effect/water/proc/on_water_step(datum/move_loop/source, step_count, succeeded)
	SIGNAL_HANDLER
	var/turf/T = get_turf(src)
	if(T && reagents)
		var/list/splash_mobs = list()
		var/list/splash_others = list(T)
		for(var/atom/A in T)
			if(A.simulated)
				if(!ismob(A))
					splash_others += A
				else if(isliving(A))
					splash_mobs += A

		//each step splash 1/5 of the reagents on non-mobs
		for(var/atom/A in splash_others)
			reagents.splash(A, (reagents.total_volume/step_count)/splash_others.len)
		for(var/mob/living/M in splash_mobs)
			reagents.splash(M, reagents.total_volume/splash_mobs.len)
		if(reagents.total_volume < 1)
			qdel(source)
			return
		var/datum/move_loop/has_target/target_loop = source
		if(istype(target_loop) && T == get_turf(target_loop.target))
			for(var/atom/A in splash_others)
				reagents.splash(A, reagents.total_volume/splash_others.len) //splash anything left
			qdel(source)
			return


/obj/effect/effect/water/proc/on_water_loop_end(datum/move_loop/source)
	SIGNAL_HANDLER
	addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, src), 10)


/obj/effect/effect/water/Move(turf/newloc)
	if(newloc.density)
		return 0
	. = ..()

/obj/effect/effect/water/Bump(atom/A)
	if(reagents)
		reagents.touch(A)
	return ..()

//Used by spraybottles.
/obj/effect/effect/water/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	icon_state = ""
