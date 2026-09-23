/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)

/mob/proc/setMoveCooldown(var/timeout)
	if(client)
		client.move_delay = max(world.time + timeout, client.move_delay)

/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))

/client/Northeast()
	diagonal_action(NORTHEAST)
/client/Northwest()
	diagonal_action(NORTHWEST)
/client/Southeast()
	diagonal_action(SOUTHEAST)
/client/Southwest()
	diagonal_action(SOUTHWEST)

/client/proc/diagonal_action(direction)
	switch(client_dir(direction, 1))
		if(NORTHEAST)
			swap_hand()
			return
		if(SOUTHEAST)
			attack_self()
			return
		if(SOUTHWEST)
			if(isliving(usr))
				var/mob/living/carbon/C = usr
				C.toggle_throw_mode()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
			return
		if(NORTHWEST)
			if(isliving(usr))
				var/mob/living/carbon/C = usr
				if(!C.get_active_hand())
					to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
					return
				drop_item()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")
			return

/mob/proc/hotkey_drop()
	to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")

/mob/living/carbon/hotkey_drop()
	if(!get_active_hand())
		to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
	else
		drop_item()

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living))
		var/mob/living/L = mob
		L.swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && isturf(mob.loc))
		return mob.drop_item()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

//This proc should never be overridden elsewhere at /atom/movable to keep directions sane.
/atom/movable/Move(newloc, direct, glide_size_override = 0)
	if(glide_size_override)
		set_glide_size(glide_size_override)

	var/atom/A = src.loc
	var/olddir = dir //we can't override this without sacrificing the rest of movable/New()
	. = ..()

	if(!. && (direct & (direct - 1)) && config.allow_diagonal_movement)
		var/first_dir = direct & (NORTH|SOUTH)
		var/second_dir = direct & (EAST|WEST)
		if(first_dir && step(src, first_dir))
			return 1
		else if(second_dir && step(src, second_dir))
			return 1
		return 0

	if(direct != olddir)
		dir = olddir
		set_dir(direct)

	src.move_speed = world.time - src.l_move_time
	src.l_move_time = world.time
	src.m_flag = 1
	if ((A != src.loc && A && A.z == src.z))
		src.last_move = get_dir(A, src.loc)
	if(.)
		Moved(A, direct)
	return .

// Called on a successful Move().
/atom/movable/proc/Moved(atom/oldloc)
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.forceMove(get_step(mob.control_object,direct))
	return


/client/Move(n, direct)
	if(!user_acted(src))
		return

	if(!mob || !n || !direct)
		return // Moved here to avoid nullrefs below

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	if(mob.control_object)	Move_object(direct)

	if(mob.incorporeal_move && isobserver(mob))
		Process_Incorpmove(direct)
		return

	if(moving)	return 0

	if(world.time < move_delay)
		return
	else
		next_move_dir_add = 0
		next_move_dir_sub = 0


	if(locate(/obj/effect/stop/, mob.loc))
		for(var/obj/effect/stop/S in mob.loc)
			if(S.victim == mob)
				return

	if(mob.stat==DEAD && isliving(mob))
		mob.ghostize()
		return

	// handle possible Eye movement
	if(mob.eyeobj)
		return mob.EyeMove(n,direct)

	if(mob.transforming)	return//This is sota the goto stop mobs from moving var

	if(Process_Grab())	return

	if(!mob.canmove)
		return

	if(isliving(mob))
		if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
			return FALSE
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			Process_Incorpmove(direct)
			return
		if(mob.client)
			if(mob.client.view != world.view) // If mob moves while zoomed in with device, unzoom them.
				for(var/obj/item/item in mob.contents)
					if(item.zoom)
						item.zoom(mob)
						break
				if(locate(/obj/item/weapon/gun/energy/sniperrifle, mob.contents))		// If mob moves while zoomed in with sniper rifle, unzoom them.
					var/obj/item/weapon/gun/energy/sniperrifle/s = locate() in mob
					if(s.zoom)
						s.zoom()
				if(locate(/obj/item/device/binoculars, mob.contents))		// If mob moves while zoomed in with binoculars, unzoom them.
					var/obj/item/device/binoculars/b = locate() in mob
					if(b.zoom)
						b.zoom()

	// Running prevents you from looking into the distance
	if(mob.m_intent == "run" && mob.zoomed == 1)
		mob.do_zoom()

	if(Process_Grab())	return

	if(!mob.canmove)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(!mob.check_solid_ground())
		if(!mob.Process_Spacemove(0))	return 0

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == 0 && M.canmove && mob.Adjacent(M))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0
					else
						M.stop_pulling()

		if(mob.pinned.len)
			to_chat(src, "<span class='notice'>You're pinned to a wall by [mob.pinned[1]]!</span>")
			return 0

		var/step_delay = 0

		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					step_delay += config.run_speed+1
				step_delay += config.run_speed
			if("walk")
				step_delay += config.walk_speed
		step_delay += mob.movement_delay()

		if((direct & (direct - 1)) && config.diagonal_movement_speed_normalization)
			step_delay *= DIAGONAL_MOVE_DELAY_MULT

		step_delay = max(round(step_delay, world.tick_lag), world.tick_lag)

		if(istype(mob.buckled, /obj/vehicle))
			//manually set move_delay for vehicles so we don't inherit any mob movement penalties
			//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
			move_delay = world.time
			//drunk driving
			if(mob.confused && prob(20)) //vehicles tend to keep moving in the same direction
				direct = turn(direct, pick(90, -90))
			return mob.buckled.relaymove(mob,direct)

		if(istype(mob.machine, /obj/machinery))
			if(mob.machine.relaymove(mob,direct))
				return

		if(mob.pulledby || mob.buckled) // Wheelchair driving!
			if(istype(mob.loc, /turf/space))
				return // No wheelchair driving in space
			if(istype(mob.pulledby, /obj/structure/bed/chair/wheelchair))
				return mob.pulledby.relaymove(mob, direct)
			else if(istype(mob.buckled, /obj/structure/bed/chair/wheelchair))
				if(ishuman(mob))
					var/mob/living/carbon/human/driver = mob
					var/obj/item/organ/external/l_hand = driver.get_organ(BP_L_HAND)
					var/obj/item/organ/external/r_hand = driver.get_organ(BP_R_HAND)
					if((!l_hand || l_hand.is_stump()) && (!r_hand || r_hand.is_stump()))
						return // No hands to drive your chair? Tough luck!
				//drunk wheelchair driving
				else if(mob.confused)
					switch(mob.m_intent)
						if("run")
							if(prob(50))	direct = turn(direct, pick(90, -90))
						if("walk")
							if(prob(25))	direct = turn(direct, pick(90, -90))
				step_delay += 2
				step_delay = max(round(step_delay, world.tick_lag), world.tick_lag)
				if(world.time - move_delay > step_delay)
					move_delay = world.time + step_delay
				else
					move_delay = max(move_delay + step_delay, world.time + world.tick_lag)
				if(mob.updating_glide_size)
					var/actual_delay = max(move_delay - world.time, world.tick_lag)
					mob.set_glide_size(DELAY_TO_GLIDE_SIZE(actual_delay))
				return mob.buckled.relaymove(mob,direct)

		if(world.time - move_delay > step_delay)
			move_delay = world.time + step_delay
		else
			move_delay = max(move_delay + step_delay, world.time + world.tick_lag)

		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/grab, mob))
			for (var/obj/item/grab/G in mob)
				move_delay = max(move_delay, world.time + G.grab_slowdown())
				var/list/L = mob.ret_grab()
				if(istype(L, /list))
					if(L.len == 2)
						L -= mob
						var/mob/M = L[1]
						if(M)
							if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
								var/turf/T = mob.loc
								var/temp_visual_delay = visual_delay
								visual_delay = 0
								if(mob.updating_glide_size)
									if(temp_visual_delay)
										mob.set_glide_size(temp_visual_delay)
									else
										var/actual_delay = max(move_delay - world.time, world.tick_lag)
										mob.set_glide_size(DELAY_TO_GLIDE_SIZE(actual_delay))
								. = ..()
								if (isturf(M.loc))
									var/diag = get_dir(mob, M)
									if ((diag - 1) & diag)
									else
										diag = null
									if ((get_dist(mob, M) > 1 || diag))
										step(M, get_dir(M.loc, T))
					else
						for(var/mob/M in L)
							M.other_mobs = 1
							if(mob != M)
								M.animate_movement = 3
						for(var/mob/M in L)
							spawn( 0 )
								step(M, direct)
								return
							spawn( 1 )
								M.other_mobs = null
								M.animate_movement = 2
								return
					G.adjust_position()
		else
			if(mob.confused)
				switch(mob.m_intent)
					if("run")
						if(prob(70))
							direct = turn(direct, pick(90, -90))
							n = get_step(mob, direct)
					if("walk")
						if(prob(35))
							direct = turn(direct, pick(90, -90))
							n = get_step(mob, direct)
			var/temp_visual_delay = visual_delay
			visual_delay = 0
			if(mob.updating_glide_size)
				if(temp_visual_delay)
					mob.set_glide_size(temp_visual_delay)
				else
					var/actual_delay = max(move_delay - world.time, world.tick_lag)
					mob.set_glide_size(DELAY_TO_GLIDE_SIZE(actual_delay))
			. = mob.SelfMove(n, direct)
		for (var/obj/item/grab/G in mob)
			if (G.assailant_reverse_facing())
				mob.set_dir(GLOB.reverse_dir[direct])
			G.assailant_moved()
		for (var/obj/item/grab/G in mob.grabbed_by)
			G.adjust_position()

		moving = 0

		if(mob.pulling)
			mob.dir = turn(mob.dir, 180)
			mob.update_vision_cone()

		return .

	return

/mob/proc/SelfMove(turf/n, direct)
	return Move(n, direct)

/mob/newtonian_move(direction)
	. = ..()
	if(!.)
		return
	if(client)
		client.visual_delay = MOVEMENT_ADJUSTED_GLIDE_SIZE(inertia_move_delay, SSspacedrift.visual_delay)


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)

	next_move_dir_add = 0
	next_move_dir_sub = 0

	if(mob.updating_glide_size)
		mob.set_glide_size(DELAY_TO_GLIDE_SIZE(world.tick_lag))

	switch(mob.incorporeal_move)
		if(1)
			var/turf/T = get_step(mob, direct)
			if(mob.check_is_holy_turf(T))
				to_chat(mob, "<span class='warning'>You cannot enter holy grounds while you are in this plane of existence!</span>")
				return
			else
				mob.forceMove(get_step(mob, direct))
				mob.dir = direct
		if(2)
			if(prob(25))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				mob.forceMove(locate(locx,locy,mobloc.z))
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						spawn(0)
							anim(T,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
				mob.forceMove(get_step(mob, direct))
			mob.dir = direct
	// Crossed is always a bit iffy
	for(var/obj/S in mob.loc)
		if(istype(S,/obj/effect/step_trigger) || istype(S,/obj/effect/beam))
			S.Crossed(mob)

	var/area/A = get_area_master(mob)
	if(A)
		A.Entered(mob)
	if(isturf(mob.loc))
		var/turf/T = mob.loc
		T.Entered(mob)
	mob.Post_Incorpmove()
	return 1

/mob/proc/Post_Incorpmove()
	return

///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/Process_Spacemove(var/check_drift = 0)
	if(check_drift)
		return check_solid_ground()

	if(!Check_Dense_Object()) //Nothing to push off of so end here
		update_floating()
		return 0

	if(restrained()) //Check to see if we can do things
		return 0

	update_floating()
	return 1

/mob/proc/check_solid_ground()
	var/turf/T = get_turf(src)
	if(!T || istype(T, /turf/space))
		return 0

	if(mob_has_gravity(T))
		//Check to see if we slipped
		if(prob(Process_Spaceslipping(0)) && !buckled)
			src << "<font color='blue'><B>You slipped!</B></font>"
			src.inertia_dir = src.last_move
			step(src, src.inertia_dir)
			return 0
		//If not then we can reset inertia and move
		inertia_dir = 0
		return 1

	if(istype(T, /turf/simulated/floor) && Check_Shoegrip())
		inertia_dir = 0
		return 1

	return 0

/mob/proc/Check_Dense_Object() //checks for anything to push off in the vicinity. also handles magboots on gravity-less floors tiles
	var/dense_object = 0
	var/shoegrip

	for(var/turf/turf in range(1, src))
		if(istype(turf, /turf/space))
			continue

		if(istype(turf, /turf/simulated/floor)) // Floors don't count if they don't have gravity
			if(!mob_has_gravity(turf))
				if(shoegrip == null)
					shoegrip = Check_Shoegrip() //Shoegrip is only ever checked when a zero-gravity floor is encountered to reduce load
				if(!shoegrip)
					continue

		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in range(1, src)))
		dense_object++

	if(!dense_object && (locate(/obj/structure/catwalk) in range(1, src)))
		dense_object++

	if(!dense_object && (locate(/obj/structure/grille) in range(1, src)))
		dense_object++

	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in range(1, src))
			if(O && O.density && O.anchored)
				dense_object++
				break

	return dense_object

/mob/proc/Check_Shoegrip()
	return 0

/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		return 0
	if(Check_Shoegrip())
		return 0
	prob_slip = round(prob_slip)
	return prob_slip

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/update_gravity()
	return
/*
// The real Move() proc is above, but touching that massive block just to put this in isn't worth it.
/mob/Move(var/newloc, var/direct)
	. = ..(newloc, direct)
	if(.)
		post_move(newloc, direct)
*/
// Called when a mob successfully moves.
// Would've been an /atom/movable proc but it caused issues.
/mob/Moved(atom/oldloc)
	for(var/obj/O in contents)
		O.on_loc_moved(oldloc)

// Received from Moved(), useful for items that need to know that their loc just moved.
/obj/proc/on_loc_moved(atom/oldloc)
	return

/obj/item/weapon/storage/on_loc_moved(atom/oldloc)
	for(var/obj/O in contents)
		O.on_loc_moved(oldloc)

/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	Move(get_step(mob, NORTH), NORTH)
/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	Move(get_step(mob, SOUTH), SOUTH)
/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	Move(get_step(mob, EAST), EAST)
/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	Move(get_step(mob, WEST), WEST)
