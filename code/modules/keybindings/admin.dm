/datum/keybinding/admin
	category = KB_CATEGORY_ADMIN
	admin = TRUE

/datum/keybinding/admin/admin_ghost
	hotkey_keys = list("F5")
	name = "admin_ghost"
	full_name = "Admin Ghost"
	description = "Enables Aghost"

/datum/keybinding/admin/admin_ghost/down(client/user)
	user.admin_ghost()
	return TRUE

/datum/keybinding/admin/player_panel
	hotkey_keys = list("F6")
	name = "player_panel"
	full_name = "Player Panel"
	description = "Opens the Player Panel"

/datum/keybinding/admin/player_panel/down(client/user)
	user.holder.player_panel_new()
	return TRUE

/datum/keybinding/admin/admin_pm
	hotkey_keys = list("F7")
	name = "admin_pm"
	full_name = "Admin PM"
	description = "Sends an Admin PM"

/datum/keybinding/admin/admin_pm/down(client/user)
	user.cmd_admin_pm_context()
	return TRUE

/datum/keybinding/admin/verbmanager
	hotkey_keys = list("F8")
	name = "vema"
	full_name = "Verb Manager"
	description = "Opens Verb Manager"

/datum/keybinding/admin/verbmanager/down(client/user)
	user.open_verb_manager()
	return TRUE
