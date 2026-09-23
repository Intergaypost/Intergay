/var/obj/effect/lobby_image = new/obj/effect/lobby_image()

/obj/effect/lobby_image
	name = "Gorodok" // god bless us
	desc = "This shouldn't be read."
	screen_loc = "WEST,SOUTH"
	mouse_opacity = 0

/obj/effect/lobby_image/Initialize()
	icon = GLOB.using_map.lobby_icon
	var/known_icon_states = icon_states(icon)
	for(var/lobby_screen in GLOB.using_map.lobby_screens)
		if(!(lobby_screen in known_icon_states))
			error("Lobby screen '[lobby_screen]' did not exist in the icon set [icon].")
			GLOB.using_map.lobby_screens -= lobby_screen

	if(GLOB.using_map.lobby_screens.len)
		icon_state = pick(GLOB.using_map.lobby_screens)
	else
		icon_state = known_icon_states[1]

	. = ..()

/mob/new_player/Login()
	..()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	to_chat(src, "<h1 class='alert'>Story ID:</h1>")

	to_chat(src, "<div class='danger'>[game_id]</div>")

	if(GAME_STATE <= RUNLEVEL_LOBBY)
		to_world("<div class='playerjoinbox'><span class='notice'>LOBBY: [usr.key] comes.</span></div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	loc = null
	client.screen += lobby_image
	my_client = client
	set_sight(sight|SEE_TURFS|SEE_OBJS)
	GLOB.player_list |= src
	//to_chat(src, "\n<div class='firstdivmood'><div class='moodbox'><span class='graytext'>This is a proof of concept.</span>\n<span class='feedback'><a href='byond://?src=\ref[src];action=agreeconcept'>This sucks ass.</a></span>\n<span class='feedback'><a href='byond://?src=\ref[src];action=refuseconcept'>No, it doesn't.</a></span></div></div>")

	client.playtitlemusic()

/*
/client/Topic(href, href_list, hsrc)
	..()
	switch(href_list["action"])
		if("agreeconcept")
			to_chat(src, "Eurika!")
*/