/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null

		/////////
		//OTHER//
		/////////

	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null
	var/visual_delay	= 0
	var/adminobs		= null


	var/adminhelped = 0

	var/staffwarn = null
	var/datum/chatOutput/chatOutput

	var/fullscreen = FALSE

	perspective = EYE_PERSPECTIVE

	var/widescreen = 0
	var/vert_split = 0

	var/datum/interfaceSizeHelper/screen/screenSizeHelper = null
	var/datum/interfaceSizeHelper/map/mapSizeHelper = null

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0

	var/pigReady = FALSE

		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0
	var/warned_about_multikeying = 0	// Prevents people from being spammed about multikeying every time their mob changes.

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "Requires database"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	/*
	As of byond 512, due to how broken preloading is, preload_rsc MUST be set to 1 at compile time if resource URLs are *not* in use,
	BUT you still want resource preloading enabled (from the server itself). If using resource URLs, it should be set to 0 and
	changed to a URL at runtime (see client_procs.dm for procs that do this automatically). More information about how goofy this broken setting works at
	http://www.byond.com/forum/post/1906517?page=2#comment23727144
	*/
	preload_rsc = 1






	var/hi_last_pos

	var/encoding = "1252"

	/// All keys currently held down.
	var/list/keys_held = list()
	/// For combinations of keys
	var/list/key_combos_held = list()
	/// Cached list of keys currently bound to movement. Key: key string, Value: direction
	var/list/movement_keys = list()
	/// All keys that are configured to bypass the check for canmove or user intent.
	var/movement_locked = FALSE
	/// Intended direction calculated from currently held movement keys
	var/intended_direction = 0
	/// Next direction to add to movement_dir
	var/next_move_dir_add = 0
	/// Next direction to subtract from movement_dir
	var/next_move_dir_sub = 0
	/// Movement dir of the most recently pressed movement key. Used in cardinal-only movement mode.
	var/last_move_dir_pressed = 0
	/// Client keypress spam prevention
	var/acted_time = 0
	var/acted_counter = 0

