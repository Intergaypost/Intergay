/datum/keybinding/movement
	category = KB_CATEGORY_MOVEMENT
	var/movement_dir = 0

/datum/keybinding/movement/north
	hotkey_keys = list("W", "North")
	name = "North"
	full_name = "Move North"
	description = "Moves your character north"
	movement_dir = NORTH

/datum/keybinding/movement/south
	hotkey_keys = list("S", "South")
	name = "South"
	full_name = "Move South"
	description = "Moves your character south"
	movement_dir = SOUTH

/datum/keybinding/movement/west
	hotkey_keys = list("A", "West")
	name = "West"
	full_name = "Move West"
	description = "Moves your character left"
	movement_dir = WEST

/datum/keybinding/movement/east
	hotkey_keys = list("D", "East")
	name = "East"
	full_name = "Move East"
	description = "Moves your character east"
	movement_dir = EAST

/datum/keybinding/movement/move_quickly
	hotkey_keys = list("Shift")
	name = "moving_quickly"
	full_name = "Move Quickly"
	description = "Makes you move quickly"

/datum/keybinding/movement/move_quickly/down(client/user)
	user.setmovingquickly()
	return TRUE

/datum/keybinding/movement/move_quickly/up(client/user)
	user.setmovingslowly()
	return TRUE
