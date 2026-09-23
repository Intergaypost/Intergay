/proc/get_personal_locker_save_path(var/ckey_val, var/char_name)
	if(!ckey_val || !char_name)
		return null
	var/clean_ckey = ckey(ckey_val)
	if(!clean_ckey)
		return null
	var/clean_name = sanitizeFileName(char_name)
	if(!clean_name)
		return null
	return "data/player_saves/[copytext(clean_ckey, 1, 2)]/[clean_ckey]/locker_[clean_name].sav"

GLOBAL_LIST_INIT(personal_locker_blacklist, list(
	/obj/item/weapon/disk/nuclear,
	/obj/item/weapon/card/id,
	/obj/item/weapon/pinpointer,
	/obj/item/weapon/storage/backpack/holding,
	/obj/item/device/uplink,
	/obj/item/device/multitool/hacktool,
	/obj/item/weapon/plastique,
	/obj/item/weapon/grenade
))

/proc/is_personal_locker_blacklisted_item(var/obj/item/I)
	if(!istype(I))
		return TRUE
	return is_type_in_list(I, GLOB.personal_locker_blacklist)

/proc/serialize_locker_item(var/obj/item/I)
	if(!istype(I) || is_personal_locker_blacklisted_item(I))
		return null

	var/list/data = list(
		"type" = "[I.type]",
		"name" = I.name,
		"desc" = I.desc
	)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		data["amount"] = S.amount

	if(istype(I, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/ST = I
		var/list/sub_items = list()
		for(var/obj/item/sub in ST.contents)
			if(sub.w_class > ITEM_SIZE_SMALL || is_personal_locker_blacklisted_item(sub))
				continue
			var/list/sub_data = serialize_locker_item(sub)
			if(sub_data)
				sub_items += list(sub_data)
		if(sub_items.len)
			data["contents"] = sub_items

	if(istype(I, /obj/item/weapon/reagent_containers) && I.reagents)
		var/list/reagents_data = list()
		for(var/datum/reagent/R in I.reagents.reagent_list)
			reagents_data["[R.type]"] = R.volume
		if(reagents_data.len)
			data["reagents"] = reagents_data

	if(istype(I, /obj/item/weapon/cell))
		var/obj/item/weapon/cell/C = I
		data["charge"] = C.charge
		data["maxcharge"] = C.maxcharge

	return data

/proc/deserialize_locker_item(var/list/data, var/atom/loc)
	if(!islist(data) || !data["type"])
		return null

	var/item_path = text2path(data["type"])
	if(!ispath(item_path, /obj/item))
		return null

	var/obj/item/I
	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/parent_storage = loc
		I = new item_path(null)
		if(!istype(I))
			return null
		if(!parent_storage.handle_item_insertion(I, prevent_warning = 1, NoUpdate = 1))
			qdel(I)
			return null
	else
		I = new item_path(loc)
		if(!istype(I))
			return null

	if(data["name"])
		I.SetName(data["name"])

	if(data["desc"])
		I.desc = data["desc"]

	if(istype(I, /obj/item/stack) && !isnull(data["amount"]))
		var/obj/item/stack/S = I
		S.amount = data["amount"]

	if(istype(I, /obj/item/weapon/storage) && islist(data["contents"]))
		for(var/list/sub_data in data["contents"])
			deserialize_locker_item(sub_data, I)

	if(istype(I, /obj/item/weapon/reagent_containers) && I.reagents && islist(data["reagents"]))
		I.reagents.clear_reagents()
		var/list/reagents_data = data["reagents"]
		for(var/reagent_type_str in reagents_data)
			var/r_path = text2path(reagent_type_str)
			if(ispath(r_path, /datum/reagent))
				I.reagents.add_reagent(r_path, reagents_data[reagent_type_str])

	if(istype(I, /obj/item/weapon/cell) && !isnull(data["charge"]))
		var/obj/item/weapon/cell/C = I
		if(!isnull(data["maxcharge"]))
			C.maxcharge = data["maxcharge"]
		C.charge = data["charge"]

	return I

/proc/save_personal_locker_data(var/obj/structure/closet/secure_closet/personal_locker/L)
	if(!istype(L) || !L.registered_ckey || !L.registered_name)
		return FALSE

	var/save_path = get_personal_locker_save_path(L.registered_ckey, L.registered_name)
	if(!save_path)
		return FALSE

	var/list/stored_items = L.get_stored_items()
	var/list/serialized_items = list()
	for(var/obj/item/I in stored_items)
		if(I.w_class <= L.max_item_w_class && !is_personal_locker_blacklisted_item(I))
			var/list/item_data = serialize_locker_item(I)
			if(item_data)
				serialized_items += list(item_data)

	var/savefile/S = new /savefile(save_path)
	if(!S)
		return FALSE

	S["version"] << 1
	S["registered_ckey"] << L.registered_ckey
	S["registered_name"] << L.registered_name
	S["lock_code"] << L.lock_code
	S["items"] << serialized_items

	return TRUE

/proc/load_personal_locker_data(var/obj/structure/closet/secure_closet/personal_locker/L, var/ckey_val, var/char_name)
	if(!istype(L) || !ckey_val || !char_name)
		return FALSE

	var/save_path = get_personal_locker_save_path(ckey_val, char_name)
	if(!save_path || !fexists(save_path))
		return FALSE

	var/savefile/S = new /savefile(save_path)
	if(!S)
		return FALSE

	var/saved_lock_code
	S["lock_code"] >> saved_lock_code
	if(saved_lock_code)
		L.lock_code = saved_lock_code

	var/list/serialized_items
	S["items"] >> serialized_items

	if(islist(serialized_items))
		for(var/list/item_data in serialized_items)
			var/list/stored = L.get_stored_items()
			if(stored.len >= L.max_items)
				break
			var/obj/item/I = deserialize_locker_item(item_data, L)
			if(I && (I.w_class > L.max_item_w_class || is_personal_locker_blacklisted_item(I)))
				qdel(I)

	// Anti-dupe protection: Clear saved items immediately once loaded into the active round.
	// If the locker is destroyed mid-round or items are taken out, they will not duplicate next round.
	// Valid remaining items will be re-saved at round end.
	S["items"] << list()

	return TRUE

/proc/clear_personal_locker_save(var/ckey_val, var/char_name = null)
	if(!ckey_val)
		return FALSE
	var/clean_ckey = ckey(ckey_val)
	if(!clean_ckey)
		return FALSE

	if(char_name)
		var/save_path = get_personal_locker_save_path(ckey_val, char_name)
		if(save_path && fexists(save_path))
			fdel(save_path)
			return TRUE
		return FALSE

	// If no character name specified, clear all locker saves for this ckey
	var/folder_path = "data/player_saves/[copytext(clean_ckey, 1, 2)]/[clean_ckey]/"
	var/list/files = flist(folder_path)
	var/cleared = FALSE
	for(var/file in files)
		if(findtext(file, "locker_") == 1 || file == "personal_locker.sav")
			fdel("[folder_path][file]")
			cleared = TRUE
	return cleared

/hook/roundend/proc/save_personal_lockers_roundend()
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.registered_ckey && L.registered_name)
			save_personal_locker_data(L)
	return 1

/hook/shutdown/proc/save_personal_lockers_shutdown()
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.registered_ckey && L.registered_name)
			save_personal_locker_data(L)
	return 1
