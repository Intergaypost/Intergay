/**
 * # Keybinding Datums
 *
 * Each instance of /datum/keybinding represents a unique action that can be performed via key inputs.
 */
/datum/keybinding
	/// The category the keybinding belongs to. See `code/modules/keybindings/_defines.dm`.
	var/category = KB_CATEGORY_CLIENT
	/// Unique name of the keybinding.
	var/name
	/// Display name of the keybinding in the UI.
	var/full_name
	/// Description of what the keybinding does.
	var/description = ""
	/// Default hotkey keys bound to this keybinding.
	var/list/hotkey_keys = list()
	/// Default classic keys (if different).
	var/list/classic_keys = list()
	/// If TRUE, the down trigger will repeat if held.
	var/repeat = FALSE
	/// If TRUE, this keybinding can only be used by admins.
	var/admin = FALSE

/datum/keybinding/proc/can_use(client/user)
	if(admin && !user.holder)
		return FALSE
	return TRUE

/datum/keybinding/proc/down(client/user)
	return FALSE

/datum/keybinding/proc/up(client/user)
	return FALSE
