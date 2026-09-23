/proc/index_all_personal_lockers()
	var/list/used_numbers = list()
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.locker_number > 0)
			used_numbers |= L.locker_number

	var/next_num = 1
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(!L.locker_number)
			while(next_num in used_numbers)
				next_num++
			L.locker_number = next_num
			used_numbers |= next_num
		L.update_locker_name()

/hook/roundstart/proc/setup_personal_lockers_index()
	index_all_personal_lockers()
	return 1

/proc/find_personal_locker_for(var/mob/living/carbon/human/H, var/player_ckey, var/player_name)
	if(!istype(H))
		return null
	if(!player_ckey)
		player_ckey = H.ckey ? H.ckey : ((H.mind && H.mind.key) ? ckey(H.mind.key) : (H.client ? H.client.ckey : null))
	if(!player_name)
		player_name = H.real_name ? H.real_name : (H.mind ? H.mind.name : H.name)
	if(!player_ckey || !player_name)
		return null

	// First check if already assigned to this player and character
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.registered_ckey == player_ckey && L.registered_name == player_name)
			return L

	// Next find an unassigned locker
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(!L.registered_ckey)
			return L

	return null

/proc/assign_personal_locker(var/mob/living/carbon/human/H)
	if(!istype(H))
		return null

	var/player_ckey = H.ckey ? H.ckey : ((H.mind && H.mind.key) ? ckey(H.mind.key) : (H.client ? H.client.ckey : null))
	var/player_name = H.real_name ? H.real_name : (H.mind ? H.mind.name : H.name)
	if(!player_ckey || !player_name)
		return null

	index_all_personal_lockers()

	var/obj/structure/closet/secure_closet/personal_locker/L = find_personal_locker_for(H, player_ckey, player_name)
	if(!L)
		log_game("No free personal locker found for [player_name] ([player_ckey])")
		to_chat(H, "<span class='info'><b>Personal Storage:</b> No unassigned personal lockers are currently available on the station.</span>")
		return null

	var/already_registered = (L.registered_ckey == player_ckey && L.registered_name == player_name)
	L.registered_ckey = player_ckey
	L.registered_name = player_name
	L.update_locker_name()

	if(!already_registered)
		load_personal_locker_data(L, player_ckey, player_name)

	// Create and give the physical locker key
	var/obj/item/weapon/key/locker_key/K = new /obj/item/weapon/key/locker_key(null, L.lock_code, L.locker_number, player_name, player_ckey)
	var/placement_msg = "in your inventory"

	// 1. Try pockets
	if(H.equip_to_slot_if_possible(K, slot_r_store, disable_warning = 1))
		placement_msg = "in your pocket"
	else if(H.equip_to_slot_if_possible(K, slot_l_store, disable_warning = 1))
		placement_msg = "in your pocket"
	// 2. Try uniform accessory / tie clip
	else if(H.equip_to_slot_if_possible(K, slot_tie, disable_warning = 1))
		placement_msg = "attached to your uniform"
	// 3. Try storage (backpack, satchel, dufflebag, belt, box)
	else if(H.equip_to_storage(K))
		if(H.back && (K in H.back.contents))
			placement_msg = "in your backpack"
		else if(H.belt && (K in H.belt.contents))
			placement_msg = "in your belt storage"
		else
			placement_msg = "in your bag"
	// 4. Try neck / amulet slot
	else if(H.equip_to_slot_if_possible(K, slot_wear_amulet, disable_warning = 1))
		placement_msg = "around your neck"
	// 5. Try hands only if not asleep
	else if(!H.sleeping && H.put_in_hands(K))
		placement_msg = "in your hand"
	// 6. Fallback: on the floor
	else
		K.forceMove(get_turf(H))
		placement_msg = "on the floor at your feet"

	to_chat(H, "<span class='notice'><b>Personal Storage:</b> You have been assigned personal locker #[L.locker_number]. Your locker key has been placed [placement_msg].</span>")
	return L
