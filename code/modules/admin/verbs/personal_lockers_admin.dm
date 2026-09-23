/client/proc/cmd_admin_personal_lockers()
	set name = "Manage Personal Lockers"
	set category = "Admin"

	if(!holder || !check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>Only administrators may use this command.</span>")
		return

	holder.personal_lockers_panel(src)

/datum/admins/proc/personal_lockers_panel(var/client/C)
	if(!check_rights(R_ADMIN))
		return

	var/dat = "<html><head><title>Personal Lockers Management</title>"
	dat += "<style>"
	dat += "body { font-family: Verdana, sans-serif; font-size: 11px; background-color: #272727; color: #fff; }"
	dat += "table { border-collapse: collapse; width: 100%; font-size: 11px; }"
	dat += "th { background-color: #383838; padding: 6px; border: 1px solid #4a4a4a; text-align: left; }"
	dat += "td { padding: 5px; border: 1px solid #4a4a4a; background-color: #2b2b2b; }"
	dat += "tr:nth-child(even) td { background-color: #323232; }"
	dat += "a { color: #5dade2; text-decoration: none; }"
	dat += "a:hover { color: #aed6f1; text-decoration: underline; }"
	dat += ".btn { background-color: #4a4a4a; padding: 2px 6px; border-radius: 3px; border: 1px solid #666; display: inline-block; margin: 1px; }"
	dat += ".locked { color: #e74c3c; font-weight: bold; }"
	dat += ".unlocked { color: #2ecc71; font-weight: bold; }"
	dat += ".broken { color: #f39c12; font-weight: bold; }"
	dat += "</style></head><body>"

	dat += "<h2>Personal Lockers Registry ([GLOB.all_personal_lockers.len] lockers total)</h2>"
	dat += "<p><a class='btn' href='?src=\ref[src];locker_refresh=1'>Refresh Panel</a> "
	dat += "<a class='btn' href='?src=\ref[src];locker_index_all=1'>Re-index All Lockers</a></p>"

	dat += "<table>"
	dat += "<tr>"
	dat += "<th>#</th>"
	dat += "<th>Name</th>"
	dat += "<th>Location</th>"
	dat += "<th>Owner</th>"
	dat += "<th>Status</th>"
	dat += "<th>Items</th>"
	dat += "<th>Actions</th>"
	dat += "</tr>"

	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		var/turf/T = get_turf(L)
		var/loc_str = T ? "[T.x], [T.y], [T.z]" : "Unknown"

		dat += "<tr>"
		dat += "<td><b>#[L.locker_number]</b></td>"
		dat += "<td>[L.name]</td>"
		dat += "<td><a href='?src=\ref[src];locker_jump=\ref[L]'>[loc_str]</a></td>"
		dat += "<td>[L.registered_name ? "[L.registered_name] ([L.registered_ckey])" : "<i>None</i>"]</td>"

		var/status_str = L.locked ? "<span class='locked'>LOCKED</span>" : "<span class='unlocked'>OPEN/UNLOCKED</span>"
		if(L.broken)
			status_str += " <span class='broken'>(BROKEN)</span>"
		dat += "<td>[status_str]</td>"

		var/list/stored = L.get_stored_items()
		dat += "<td>[stored.len]/[L.max_items]</td>"

		dat += "<td>"
		dat += "<a class='btn' href='?src=\ref[src];locker_toggle_lock=\ref[L]'>Lock/Unlock</a> "
		dat += "<a class='btn' href='?src=\ref[src];locker_spawn_key=\ref[L]'>Spawn Key</a> "
		if(L.registered_ckey)
			dat += "<a class='btn' href='?src=\ref[src];locker_give_key=\ref[L]'>Give Key to Owner</a> "
			dat += "<a class='btn' href='?src=\ref[src];locker_reset_owner=\ref[L]'>Reset Owner</a> "
			dat += "<a class='btn' href='?src=\ref[src];locker_wipe_save=\ref[L]'>Wipe Save</a> "
		dat += "<a class='btn' href='?src=\ref[src];locker_view_contents=\ref[L]'>View Contents</a> "
		dat += "<a class='btn' href='?src=\ref[src];locker_clear_contents=\ref[L]'>Clear Contents</a>"
		dat += "</td>"

		dat += "</tr>"

	dat += "</table>"
	dat += "</body></html>"

	C << browse(dat, "window=personal_lockers;size=900x600")

/datum/admins/proc/handle_locker_topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return FALSE

	if(href_list["locker_refresh"])
		personal_lockers_panel(usr.client)
		return TRUE

	if(href_list["locker_index_all"])
		index_all_personal_lockers()
		to_chat(usr, "<span class='notice'>All personal lockers re-indexed.</span>")
		personal_lockers_panel(usr.client)
		return TRUE

	if(href_list["locker_jump"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_jump"])
		if(L)
			usr.forceMove(get_turf(L))
			log_admin("[key_name(usr)] jumped to [L] at [L.x],[L.y],[L.z]")
		return TRUE

	if(href_list["locker_toggle_lock"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_toggle_lock"])
		if(L)
			if(L.opened && !L.locked)
				to_chat(usr, "<span class='warning'>Cannot lock [L] while it is open. Close it first.</span>")
				return TRUE
			L.locked = !L.locked
			if(L.broken)
				L.broken = FALSE
			L.update_icon()
			log_admin("[key_name(usr)] toggled lock on [L] (now [L.locked ? "locked" : "unlocked"]).")
			message_admins("[key_name_admin(usr)] toggled lock on [L] (now [L.locked ? "locked" : "unlocked"]).")
			personal_lockers_panel(usr.client)
		return TRUE

	if(href_list["locker_spawn_key"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_spawn_key"])
		if(L)
			var/obj/item/weapon/key/locker_key/K = new /obj/item/weapon/key/locker_key(null, L.lock_code, L.locker_number, L.registered_name, L.registered_ckey)
			if(!usr.put_in_hands(K))
				K.forceMove(get_turf(usr))
				to_chat(usr, "<span class='notice'>Spawned a key for [L] on the floor.</span>")
			else
				to_chat(usr, "<span class='notice'>Spawned a key for [L] in your hands.</span>")
			log_admin("[key_name(usr)] spawned a key for [L].")
			message_admins("[key_name_admin(usr)] spawned a key for [L].")
		return TRUE

	if(href_list["locker_give_key"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_give_key"])
		if(L && L.registered_ckey)
			var/mob/living/carbon/human/target = null
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.ckey == L.registered_ckey && (!L.registered_name || H.real_name == L.registered_name))
					target = H
					break
			if(target)
				var/obj/item/weapon/key/locker_key/K = new /obj/item/weapon/key/locker_key(null, L.lock_code, L.locker_number, L.registered_name, L.registered_ckey)
				var/given = FALSE
				if(target.equip_to_slot_if_possible(K, slot_r_store))
					given = TRUE
				else if(target.equip_to_slot_if_possible(K, slot_l_store))
					given = TRUE
				else if(target.put_in_hands(K))
					given = TRUE
				else if(istype(target.back, /obj/item/weapon/storage))
					var/obj/item/weapon/storage/S = target.back
					if(S.handle_item_insertion(K, prevent_warning = 1, NoUpdate = 1))
						given = TRUE

				if(!given)
					K.forceMove(get_turf(target))

				to_chat(target, "<span class='notice'>An administrator has provided you with a replacement key for your personal locker.</span>")
				to_chat(usr, "<span class='notice'>Key delivered to [target.name] ([target.ckey]).</span>")
				log_admin("[key_name(usr)] gave replacement key for [L] to [key_name(target)].")
				message_admins("[key_name_admin(usr)] gave replacement key for [L] to [key_name_admin(target)].")
			else
				to_chat(usr, "<span class='warning'>Owner [L.registered_name] ([L.registered_ckey]) is not currently online in a human mob.</span>")
		return TRUE

	if(href_list["locker_reset_owner"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_reset_owner"])
		if(L)
			var/old_owner = "[L.registered_name] ([L.registered_ckey])"
			L.registered_ckey = null
			L.registered_name = null
			L.lock_code = generateRandomString(8)
			L.update_locker_name()
			log_admin("[key_name(usr)] reset ownership of [L] (was [old_owner], generated new lock code).")
			message_admins("[key_name_admin(usr)] reset ownership of [L] (was [old_owner], generated new lock code).")
			personal_lockers_panel(usr.client)
		return TRUE

	if(href_list["locker_wipe_save"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_wipe_save"])
		if(L && L.registered_ckey)
			var/confirm = alert(usr, "Are you sure you want to wipe the saved personal locker data for [L.registered_name] ([L.registered_ckey])?", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				clear_personal_locker_save(L.registered_ckey, L.registered_name)
				log_admin("[key_name(usr)] wiped personal locker savefile for [L.registered_name] ([L.registered_ckey]).")
				message_admins("[key_name_admin(usr)] wiped personal locker savefile for [L.registered_name] ([L.registered_ckey]).")
				to_chat(usr, "<span class='notice'>Savefile wiped for [L.registered_name] ([L.registered_ckey]).</span>")
				personal_lockers_panel(usr.client)
		return TRUE

	if(href_list["locker_view_contents"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_view_contents"])
		if(L)
			var/list/stored = L.get_stored_items()
			var/list/item_names = list()
			for(var/obj/item/I in stored)
				item_names += "\ref[I] - [I.name] ([I.type])"
			if(!item_names.len)
				to_chat(usr, "<span class='info'>[L] is currently empty.</span>")
			else
				to_chat(usr, "<span class='info'>[L] contents ([stored.len]/[L.max_items]):\n[jointext(item_names, "\n")]</span>")
		return TRUE

	if(href_list["locker_clear_contents"])
		var/obj/structure/closet/secure_closet/personal_locker/L = locate(href_list["locker_clear_contents"])
		if(L)
			var/confirm = alert(usr, "Delete all contents inside [L]?", "Clear Locker Contents", "Yes", "No")
			if(confirm == "Yes")
				for(var/obj/item/I in L.get_stored_items())
					qdel(I)
				log_admin("[key_name(usr)] cleared contents of [L].")
				message_admins("[key_name_admin(usr)] cleared contents of [L].")
				personal_lockers_panel(usr.client)
		return TRUE

	return FALSE

/obj/structure/closet/secure_closet/personal_locker/verb/admin_toggle_lock()
	set name = "Admin: Toggle Lock"
	set category = "Admin"
	set src in view()

	if(!check_rights(R_ADMIN))
		return
	if(opened && !locked)
		to_chat(usr, "<span class='warning'>Cannot lock \the [src] while it is open. Close it first.</span>")
		return
	locked = !locked
	if(broken)
		broken = FALSE
	update_icon()
	log_admin("[key_name(usr)] toggled lock on [src] (now [locked ? "locked" : "unlocked"]).")
	message_admins("[key_name_admin(usr)] toggled lock on [src] (now [locked ? "locked" : "unlocked"]).")
	to_chat(usr, "<span class='notice'>You [locked ? "locked" : "unlocked"] \the [src].</span>")

/obj/structure/closet/secure_closet/personal_locker/verb/admin_spawn_key()
	set name = "Admin: Spawn Key"
	set category = "Admin"
	set src in view()

	if(!check_rights(R_ADMIN))
		return
	var/obj/item/weapon/key/locker_key/K = new /obj/item/weapon/key/locker_key(null, lock_code, locker_number, registered_name, registered_ckey)
	if(!usr.put_in_hands(K))
		K.forceMove(get_turf(usr))
		to_chat(usr, "<span class='notice'>Spawned a key for \the [src] on the floor.</span>")
	else
		to_chat(usr, "<span class='notice'>Spawned a key for \the [src] in your hands.</span>")
	log_admin("[key_name(usr)] spawned a key for [src].")
	message_admins("[key_name_admin(usr)] spawned a key for [src].")

/obj/structure/closet/secure_closet/personal_locker/verb/admin_reset_owner()
	set name = "Admin: Reset Owner"
	set category = "Admin"
	set src in view()

	if(!check_rights(R_ADMIN))
		return
	var/old_name = registered_name
	registered_ckey = null
	registered_name = null
	lock_code = generateRandomString(8)
	update_locker_name()
	log_admin("[key_name(usr)] reset owner of [src] (was [old_name], generated new lock code).")
	message_admins("[key_name_admin(usr)] reset owner of [src] (was [old_name], generated new lock code).")
	to_chat(usr, "<span class='notice'>Owner reset for \the [src] (new lock code generated).</span>")
