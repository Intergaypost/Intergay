GLOBAL_LIST_EMPTY(all_personal_lockers)

/obj/structure/closet/secure_closet/personal_locker
	name = "personal locker"
	desc = "A secure personal storage unit bolted to the deck. It has a keyhole for a physical key."
	icon_state = "ntr"
	icon_closed = "ntr"
	icon_locked = "ntr"
	icon_opened = "ntropen"
	icon_off = "ntr"

	anchored = TRUE
	locked = TRUE
	setup = CLOSET_HAS_LOCK | CLOSET_CAN_BE_WELDED
	storage_types = CLOSET_STORAGE_ITEMS

	var/max_items = 6
	var/max_item_w_class = ITEM_SIZE_SMALL
	var/lock_code = null
	var/registered_ckey = null
	var/registered_name = null
	var/locker_number = 0

/obj/structure/closet/secure_closet/personal_locker/Initialize()
	. = ..()
	if(!lock_code)
		lock_code = generateRandomString(8)
	GLOB.all_personal_lockers |= src
	update_locker_name()

/obj/structure/closet/secure_closet/personal_locker/Destroy()
	GLOB.all_personal_lockers -= src
	return ..()

/obj/structure/closet/secure_closet/personal_locker/proc/update_locker_name()
	var/num_tag = locker_number ? "#[locker_number] " : ""
	if(registered_name)
		name = "personal locker [num_tag]([registered_name])"
		desc = "A secure personal storage unit bolted to the deck, assigned to [registered_name]."
	else
		name = "personal locker [num_tag](unassigned)"
		desc = "A secure personal storage unit bolted to the deck. It is currently unassigned."

/obj/structure/closet/secure_closet/personal_locker/proc/get_stored_items()
	var/list/items = list()
	for(var/obj/item/I in contents)
		if(I.w_class <= max_item_w_class && !is_personal_locker_blacklisted_item(I))
			items |= I
	if(opened && loc)
		for(var/obj/item/I in loc)
			if(!I.anchored && I.w_class <= max_item_w_class && !is_personal_locker_blacklisted_item(I))
				if(items.len >= max_items)
					break
				items |= I
	return items

/obj/structure/closet/secure_closet/personal_locker/examine(mob/user)
	..(user)
	to_chat(user, "<span class='info'>It is securely bolted to the deck.</span>")
	if(registered_name)
		to_chat(user, "<span class='notice'>It belongs to [registered_name].</span>")
	else
		to_chat(user, "<span class='notice'>It is currently not assigned to anyone.</span>")
	if(opened)
		var/list/stored = get_stored_items()
		to_chat(user, "<span class='notice'>Space used: [stored.len]/[max_items] slots (Max item size: SMALL).</span>")
	if(broken)
		to_chat(user, "<span class='warning'>The lock mechanism is broken and must be repaired with a welding tool.</span>")

/obj/structure/closet/secure_closet/personal_locker/content_size(atom/movable/AM)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.w_class > max_item_w_class || is_personal_locker_blacklisted_item(I))
			return INFINITY
		if(contents.len >= max_items && !(I in contents))
			return INFINITY
		return 1
	return INFINITY

/obj/structure/closet/secure_closet/personal_locker/store_items(var/stored_units)
	. = 0
	for(var/obj/item/I in loc)
		if(I.anchored)
			continue
		if(I.w_class > max_item_w_class || is_personal_locker_blacklisted_item(I))
			continue
		if(contents.len + . >= max_items)
			break
		.++
		I.forceMove(src)
		I.pixel_x = 0
		I.pixel_y = 0
		I.pixel_z = 0

/obj/structure/closet/secure_closet/personal_locker/make_broken()
	if(broken)
		return FALSE
	broken = TRUE
	locked = FALSE
	update_icon()
	return TRUE

/obj/structure/closet/secure_closet/personal_locker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/grab) || istype(W, /obj/item/tk_grab))
			return 0
		if(isWelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				slice_into_parts(WT, user)
				return
		if(istype(W, /obj/item))
			if(is_personal_locker_blacklisted_item(W))
				to_chat(user, "<span class='warning'>\The [W] cannot be safely stored in personal storage.</span>")
				return 0
			if(W.w_class > max_item_w_class)
				to_chat(user, "<span class='warning'>\The [W] is too large for \the [src]. Only small items (ITEM_SIZE_SMALL or smaller) fit here.</span>")
				return 0
			var/list/stored = get_stored_items()
			if(stored.len >= max_items)
				to_chat(user, "<span class='warning'>\The [src] is full! It can only hold up to [max_items] items.</span>")
				return 0
			if(user.drop_from_inventory(W, src.loc))
				W.pixel_x = 0
				W.pixel_y = 0
				W.pixel_z = 0
				to_chat(user, "<span class='notice'>You place \the [W] into \the [src].</span>")
				return 1
		return ..()

	// If locker is closed:
	if(isWelder(W))
		if(broken)
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>Turn \the [WT] on first.</span>")
				return
			if(!WT.remove_fuel(1, user))
				to_chat(user, "<span class='warning'>You need at least 1 unit of welding fuel to repair \the [src].</span>")
				return
			user.visible_message("<span class='notice'>[user] begins repairing the lock mechanism on \the [src] with \the [WT]...</span>", \
								 "<span class='notice'>You begin repairing the lock mechanism on \the [src] with \the [WT]...</span>")
			playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, 60, src))
				if(broken)
					broken = FALSE
					locked = FALSE
					update_icon()
					to_chat(user, "<span class='notice'>You successfully repair \the [src]'s lock mechanism.</span>")
					user.visible_message("<span class='notice'>[user] successfully repairs \the [src]'s lock mechanism.</span>")
			return

	if(istype(W, /obj/item/weapon/key))
		togglelock(user, W)
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		to_chat(user, "<span class='warning'>\The [src] has a mechanical tumbler keyhole and does not have an electronic ID card reader.</span>")
		return

	if(isCrowbar(W))
		if(!locked)
			to_chat(user, "<span class='notice'>\The [src] is already unlocked. Just open it.</span>")
			return
		if(broken)
			to_chat(user, "<span class='notice'>The lock is already broken. Just open it.</span>")
			return
		user.visible_message("<span class='warning'>[user] begins to pry open \the [src]'s lock with \the [W]!</span>", \
							 "<span class='warning'>You begin to pry open \the [src]'s lock with \the [W]...</span>")
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		if(do_after(user, 150, src))
			if(locked && !broken)
				playsound(src.loc, 'sound/effects/grillehit.ogg', 60, 1)
				make_broken()
				user.visible_message("<span class='danger'>[user] snaps open the lock mechanism of \the [src] with \the [W]!</span>", \
									 "<span class='notice'>You snap the lock mechanism open!</span>")
				open()
		return

	if(W.lock_picking_level > 0)
		if(!locked)
			to_chat(user, "<span class='notice'>\The [src] is already unlocked.</span>")
			return
		if(broken)
			to_chat(user, "<span class='warning'>The lock on \the [src] is broken and cannot be picked. Repair it first.</span>")
			return

		user.visible_message("<span class='warning'>[user] begins carefully picking \the [src]'s lock with \the [W].</span>", \
							 "<span class='notice'>You begin carefully picking \the [src]'s lock with \the [W]... This will take significant time.</span>")

		// Lockpicking takes ~60-90 seconds, split into 3 tense stages
		var/stage_delay = round(300 / (W.lock_picking_level / 3))

		for(var/stage in 1 to 3)
			if(!do_after(user, stage_delay, src))
				to_chat(user, "<span class='warning'>You lose concentration and stop picking the lock.</span>")
				return
			if(opened || !locked || broken)
				return

			playsound(src.loc, 'sound/effects/pop.ogg', 30, 1)
			if(stage < 3)
				user.visible_message("<span class='warning'>[user] continues carefully manipulating the lock tumblers on \the [src] with \the [W]...</span>", \
									 "<span class='notice'>You successfully align tumbler stage [stage]/3... continuing to work on the lock.</span>")

		// High failure rate: Rods (level 3): 15% success. Pro Lockpick (level 5): 30% success.
		var/success_chance = clamp(10 + (W.lock_picking_level * 4), 10, 35)

		if(prob(success_chance))
			playsound(src.loc, 'sound/machines/locker_unlock.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You hear a satisfying click as the final tumblers align!</span>")
			user.visible_message("<span class='warning'>[user] successfully picks the lock on \the [src]!</span>")
			locked = FALSE
			update_icon()
			open()
		else if(prob(25))
			playsound(src.loc, 'sound/effects/grillehit.ogg', 60, 1)
			to_chat(user, "<span class='danger'>Your [W] slips awkwardly and jams the delicate lock mechanism!</span>")
			user.visible_message("<span class='danger'>[user]'s [W] slips and jams the lock on \the [src]!</span>")
			make_broken()
		else
			playsound(src.loc, 'sound/effects/pop.ogg', 40, 1)
			to_chat(user, "<span class='warning'>The tumblers reset with a quiet click. You failed to pick the lock.</span>")
		return

	return ..()

/obj/structure/closet/secure_closet/personal_locker/CanToggleLock(var/mob/user, var/obj/item/weapon/key/K)
	if(!K && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/held_active = H.get_active_hand()
		if(istype(held_active, /obj/item/weapon/key))
			K = held_active
		else
			var/obj/item/held_inactive = H.get_inactive_hand()
			if(istype(held_inactive, /obj/item/weapon/key))
				K = held_inactive

	if(istype(K, /obj/item/weapon/key))
		return (K.get_data(user) == lock_code)
	return FALSE

/obj/structure/closet/secure_closet/personal_locker/emag_act(var/remaining_charges, var/mob/user, var/emag_source, var/visual_feedback = "", var/audible_feedback = "")
	if(make_broken())
		update_icon()
		visible_message("<span class='danger'>\The [src]'s lock sparks violently and gives way!</span>", "You hear a faint electrical spark.")
		open()
		return 1
	return 0
