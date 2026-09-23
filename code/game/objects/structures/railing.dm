/obj/structure/railing
	name = "railing"
	desc = "A standard steel railing. Prevents human stupidity."
	icon = 'icons/obj/railing.dmi'
	icon_state = "railing0"
	density = 1
	throwpass = 1
	layer = ABOVE_HUMAN_LAYER
	anchored = 1
	atom_flags = ATOM_FLAG_CHECKS_BORDER | ATOM_FLAG_CLIMBABLE
	var/health = 70
	var/maxhealth = 70
	var/check = 0

/obj/structure/railing/Initialize(loc, constructed = FALSE)
	. = ..()
	if(constructed)
		anchored = FALSE
	if(anchored)
		update_icon(FALSE)

/obj/structure/railing/Destroy()
	for(var/thing in trange(1, src))
		var/turf/T = thing
		for(var/obj/structure/railing/R in T)
			if(R != src)
				R.update_icon()
	return ..()

/obj/structure/railing/proc/neighbor_turf_passable()
	var/turf/T = get_step(src, dir)
	if(!T || !istype(T) || T.density || T.turf_is_crowded())
		return FALSE
	return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(!istype(mover) || mover.checkpass(PASS_FLAG_TABLE))
		return TRUE
	if(get_dir(loc, target) & dir)
		return !density
	return TRUE

/obj/structure/railing/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && O.checkpass(PASS_FLAG_TABLE))
		return TRUE
	if(get_dir(get_turf(O), target) & dir)
		return !density
	return TRUE

/obj/structure/railing/examine(mob/user)
	. = ..()
	if(health < maxhealth)
		switch(health / maxhealth)
			if(0.0 to 0.25)
				to_chat(user, "<span class='warning'>It looks severely damaged!</span>")
			if(0.25 to 0.5)
				to_chat(user, "<span class='warning'>It looks damaged!</span>")
			if(0.5 to 1.0)
				to_chat(user, "<span class='notice'>It has a few scrapes and dents.</span>")

/obj/structure/railing/proc/take_damage(amount)
	health -= amount
	if(health <= 0)
		visible_message("<span class='warning'>\The [src] breaks down!</span>")
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		new /obj/item/stack/rods(get_turf(src))
		qdel(src)

/obj/structure/railing/proc/NeighborsCheck(UpdateNeighbors = TRUE)
	check = 0
	var/Rturn = turn(dir, -90)
	var/Lturn = turn(dir, 90)

	// Check same turf for railings facing left or right
	for(var/obj/structure/railing/R in loc)
		if(R == src || !R.anchored)
			continue
		if(R.dir == Lturn)
			check |= 32
			if(UpdateNeighbors)
				R.update_icon(FALSE)
		if(R.dir == Rturn)
			check |= 2
			if(UpdateNeighbors)
				R.update_icon(FALSE)

	// Check left neighbor turf
	for(var/obj/structure/railing/R in get_step(src, Lturn))
		if(R.anchored && R.dir == dir)
			check |= 16
			if(UpdateNeighbors)
				R.update_icon(FALSE)

	// Check right neighbor turf
	for(var/obj/structure/railing/R in get_step(src, Rturn))
		if(R.anchored && R.dir == dir)
			check |= 1
			if(UpdateNeighbors)
				R.update_icon(FALSE)

	// Check forward-left diagonal neighbor turf
	for(var/obj/structure/railing/R in get_step(src, (Lturn + dir)))
		if(R.anchored && R.dir == Rturn)
			check |= 64
			if(UpdateNeighbors)
				R.update_icon(FALSE)

	// Check forward-right diagonal neighbor turf
	for(var/obj/structure/railing/R in get_step(src, (Rturn + dir)))
		if(R.anchored && R.dir == Lturn)
			check |= 4
			if(UpdateNeighbors)
				R.update_icon(FALSE)

/obj/structure/railing/update_icon(UpdateNeighbors = TRUE)
	NeighborsCheck(UpdateNeighbors)
	overlays.Cut()
	if(!check || !anchored)
		icon_state = "railing0"
	else
		icon_state = "railing1"
		// Left side
		if(check & 32)
			overlays += image('icons/obj/railing.dmi', src, "corneroverlay")
		if((check & 16) || !(check & 32) || (check & 64))
			overlays += image('icons/obj/railing.dmi', src, "frontoverlay_l")

		// Right side
		if(!(check & 2) || (check & 1) || (check & 4))
			overlays += image('icons/obj/railing.dmi', src, "frontoverlay_r")
			if(check & 4)
				switch(dir)
					if(NORTH)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = 32)
					if(SOUTH)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = -32)
					if(EAST)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = -32)
					if(WEST)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = 32)

/obj/structure/railing/verb/rotate()
	set name = "Rotate Railing Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor therefore you can't rotate it!</span>")
		return FALSE

	set_dir(turn(dir, 90))
	update_icon()

/obj/structure/railing/verb/revrotate()
	set name = "Rotate Railing Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor therefore you can't rotate it!</span>")
		return FALSE

	set_dir(turn(dir, -90))
	update_icon()

/obj/structure/railing/verb/flip()
	set name = "Flip Railing"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return FALSE

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor therefore you can't flip it!</span>")
		return FALSE

	var/turf/T = get_step(src, dir)
	if(!T || !neighbor_turf_passable())
		to_chat(usr, "<span class='warning'>You can't flip \the [src] because something is blocking it.</span>")
		return FALSE

	forceMove(T)
	set_dir(turn(dir, 180))
	update_icon()

/obj/structure/railing/attackby(obj/item/W, mob/user)
	// Dismantle
	if(istype(W, /obj/item/weapon/wrench) && !anchored)
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 20, src))
			user.visible_message("<span class='notice'>\The [user] dismantles \the [src].</span>", "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/stack/material/steel(get_turf(src), 2)
			qdel(src)
		return

	// Repair
	if(health < maxhealth && istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			playsound(loc, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, 20, src))
				if(!WT.remove_fuel(1, user))
					return
				user.visible_message("<span class='notice'>\The [user] repairs some damage to \the [src].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
				health = min(health + (maxhealth / 5), maxhealth)
		return

	// Install / Uninstall
	if(istype(W, /obj/item/weapon/screwdriver))
		user.visible_message(anchored ? "<span class='notice'>\The [user] begins to unscrew \the [src].</span>" : "<span class='notice'>\The [user] begins to fasten \the [src].</span>")
		playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
		if(do_after(user, 10, src))
			to_chat(user, anchored ? "<span class='notice'>You have unfastened \the [src] from the floor.</span>" : "<span class='notice'>You have fastened \the [src] to the floor.</span>")
			anchored = !anchored
			update_icon()
		return

	// Handle harm intent grabbing / slamming over railing
	if(istype(W, /obj/item/grab) && get_dist(src, user) < 2)
		var/obj/item/grab/G = W
		if(istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/obj/occupied = turf_is_crowded()
			if(occupied)
				to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
				return
			if(G.current_grab < 2)
				if(user.a_intent == I_HURT)
					if(prob(15))
						M.Weaken(5)
					M.apply_damage(8, def_zone = "head")
					take_damage(8)
					visible_message("<span class='danger'>[G.assailant] slams [G.affecting]'s face against \the [src]!</span>")
					playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
				else
					to_chat(user, "<span class='danger'>You need a better grip to do that!</span>")
					return
			else
				if(get_turf(G.affecting) == get_turf(src))
					G.affecting.forceMove(get_step(src, dir))
				else
					G.affecting.forceMove(get_turf(src))
				G.affecting.Weaken(5)
				visible_message("<span class='danger'>[G.assailant] throws [G.affecting] over \the [src]!</span>")
			qdel(W)
		return

	if(W.force)
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		take_damage(W.force)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	return ..()

/obj/structure/railing/ex_act(severity)
	switch(severity)
		if(1.0, 2.0, 3.0)
			qdel(src)

/obj/structure/railing/can_climb(mob/living/user, post_climb_check = FALSE)
	. = ..()
	if(. && get_turf(user) == get_turf(src))
		var/turf/T = get_step(src, dir)
		if(!T || T.density || T.turf_is_crowded())
			to_chat(user, "<span class='warning'>You can't climb there, the way is blocked.</span>")
			return FALSE

/obj/structure/railing/do_climb(mob/living/user)
	if(!can_climb(user))
		return

	user.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climbers |= user

	var/climb_time = (issmall(user) ? 24 : 30) - stat_to_modifier(user.stats[STAT_DX]) * 5
	if(!do_after(user, climb_time, src))
		climbers -= user
		return

	if(!can_climb(user, post_climb_check = TRUE))
		climbers -= user
		return

	if(!neighbor_turf_passable())
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		climbers -= user
		return

	if(get_turf(user) == get_turf(src))
		user.forceMove(get_step(src, dir))
	else
		user.forceMove(get_turf(src))

	user.visible_message("<span class='warning'>[user] climbed over \the [src]!</span>")
	if(!anchored)
		take_damage(maxhealth)
	climbers -= user

/obj/structure/railing/proc/slam_into(mob/living/L)
	var/turf/target_turf = get_turf(src)
	if(target_turf == get_turf(L))
		target_turf = get_step(src, dir)
	if(target_turf && !target_turf.density && !target_turf.turf_is_crowded())
		L.forceMove(target_turf)
		L.visible_message("<span class='warning'>\The [L] [pick("falls", "flies")] over \the [src]!</span>")
		L.Weaken(2)
		playsound(L, 'sound/effects/grillehit.ogg', 25, 1, 0)
		return TRUE
	return FALSE

/obj/structure/railing/hitby(atom/movable/AM, speed)
	var/mob/living/L = AM
	if(!istype(L))
		return ..()
	if(prob(50))
		slam_into(L)
	else
		return ..()

/obj/structure/railing/smallwall
	name = "small wall"
	desc = "A small wall, designed to keep intruders out."
	icon = 'icons/obj/railing.dmi'
	icon_state = "smallwall0"
	density = 0
	throwpass = 0
	layer = ABOVE_HUMAN_LAYER
	anchored = 1
	atom_flags = ATOM_FLAG_CHECKS_BORDER
	opacity = 1
	health = 600
	maxhealth = 600

/obj/structure/railing/smallwall/do_climb(mob/living/user)
	return FALSE

/obj/structure/railing/smallwall/rotate()
	set name = "Rotate Railing Counter-Clockwise"
	set category = "Object"
	set hidden = 1
	return FALSE

/obj/structure/railing/smallwall/revrotate()
	set name = "Rotate Railing Clockwise"
	set category = "Object"
	set hidden = 1
	return FALSE

/obj/structure/railing/smallwall/flip()
	set name = "Flip Railing"
	set category = "Object"
	set hidden = 1
	return FALSE

/obj/structure/railing/smallwall/CheckExit(atom/movable/O, turf/target)
	if(get_dir(loc, target) & dir)
		return FALSE
	return TRUE

/obj/structure/railing/smallwall/attackby(obj/item/W, mob/user)
	playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
	take_damage(W.force)
	return ..()
