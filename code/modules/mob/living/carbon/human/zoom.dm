/*
For zooming. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/

/mob/
	var/zoom = 0

/mob/verb/zoom(mob/user) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	set category = "IC"
	set name = "Look into distance"
	set hidden = 1
	var/viewsize = 9

	if(!user.client)
		return

	var/cannotzoom

	var/mob/living/carbon/human/H = user
	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, "<span class='warning'>You are unable to focus your vision.</span>")
		cannotzoom = 1
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, "<span class='warning'>Your visor gets in the way of looking into distance.</span>")
		cannotzoom = 1

	if(!zoom && !cannotzoom)
		if(user.hud_used.hud_shown)
			user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		user.client.view = viewsize
		zoom = 1

		var/tileoffset = 9
		var/tilesize = 20
		var/viewoffset = tilesize * tileoffset

		switch(src.dir)
			if (NORTH)
				src.client.pixel_x = 0
				src.client.pixel_y = viewoffset
			if (SOUTH)
				src.client.pixel_x = 0
				src.client.pixel_y = -viewoffset
			if (EAST)
				src.client.pixel_x = viewoffset
				src.client.pixel_y = 0
			if (WEST)
				src.client.pixel_x = -viewoffset
				src.client.pixel_y = 0
		src.visible_message("[src] looks off into the distance.")
		if(ishuman(user))
			var/mob/living/carbon/human/HM = user
			HM.SetFov(0)
		src.m_intent = "walk"

	else
		user.client.view = world.view
		if(!user.hud_used.hud_shown)
			user.toggle_zoom_hud()
		zoom = 0

		src.client.pixel_x = 0
		src.client.pixel_y = 0

		src.m_intent = "run"

		if(!cannotzoom)
			user.visible_message("[src] stops looking into distance.")
		if(ishuman(user))
			var/mob/living/carbon/human/HM = user
			HM.SetFov(1)

	return
