/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	body_parts_covered = FACE
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.90
	voicechange = 1

/obj/item/clothing/mask/muzzle/tape
	name = "length of tape"
	desc = "It's a robust DIY muzzle!"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape_cross"
	item_state = null
	w_class = ITEM_SIZE_TINY

/obj/item/clothing/mask/muzzle/Initialize()
	. = ..()
	say_messages = list("Mmfph!", "Mmmf mrrfff!", "Mmmf mnnf!")
	say_verbs = list("mumbles", "says")

// Clumsy folks can't take the mask off themselves.
/obj/item/clothing/mask/muzzle/attack_hand(mob/user as mob)
	if(user.wear_mask == src && !user.IsAdvancedToolUser())
		return 0
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = ITEM_SIZE_SMALL
	body_parts_covered = FACE
	item_flags = ITEM_FLAG_FLEXIBLEMATERIAL
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 0)
	down_gas_transfer_coefficient = 1
	down_body_parts_covered = null
	down_icon_state = "steriledown"
	pull_mask = 1

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|BLOCKHAIR
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/ai
	name = "camera MIU"
	desc = "Allows for direct mental connection to accessible camera networks."
	icon_state = "s-ninja"
	item_state = "s-ninja"
	flags_inv = HIDEFACE
	body_parts_covered = FACE|EYES
	action_button_name = "Toggle MUI"
	origin_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 5)
	var/active = FALSE
	var/mob/observer/eye/cameranet/eye

/obj/item/clothing/mask/ai/New()
	eye = new(src)
	eye.name_sufix = "camera MIU"
	..()

/obj/item/clothing/mask/ai/Destroy()
	if(eye)
		if(active)
			disengage_mask(eye.owner)
		qdel(eye)
		eye = null
	..()

/obj/item/clothing/mask/ai/attack_self(var/mob/user)
	if(user.incapacitated())
		return
	active = !active
	to_chat(user, "<span class='notice'>You [active ? "" : "dis"]engage \the [src].</span>")
	if(active)
		engage_mask(user)
	else
		disengage_mask(user)

/obj/item/clothing/mask/ai/equipped(var/mob/user, var/slot)
	..(user, slot)
	engage_mask(user)

/obj/item/clothing/mask/ai/dropped(var/mob/user)
	..()
	disengage_mask(user)

/obj/item/clothing/mask/ai/proc/engage_mask(var/mob/user)
	if(!active)
		return
	if(user.get_equipped_item(slot_wear_mask) != src)
		return

	eye.possess(user)
	to_chat(eye.owner, "<span class='notice'>You feel disorented for a moment as your mind connects to the camera network.</span>")

/obj/item/clothing/mask/ai/proc/disengage_mask(var/mob/user)
	if(user == eye.owner)
		to_chat(eye.owner, "<span class='notice'>You feel disorented for a moment as your mind disconnects from the camera network.</span>")
		eye.release(eye.owner)
		eye.forceMove(src)

/obj/item/clothing/mask/rubber
	name = "rubber mask"
	desc = "A rubber mask."
	icon_state = "balaclava"
	flags_inv = HIDEFACE|BLOCKHAIR
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/rubber/species
	name = "human mask"
	desc = "A rubber human mask."
	icon_state = "manmet"
	var/species = SPECIES_HUMAN

/obj/item/clothing/mask/rubber/species/New()
	..()
	visible_name = species
	var/datum/species/S = all_species[species]
	if(istype(S))
		visible_name = S.get_random_name(pick(MALE,FEMALE))

/obj/item/clothing/mask/spirit
	name = "spirit mask"
	desc = "An eerie mask of ancient, pitted wood."
	icon_state = "spirit_mask"
	item_state = "spirit_mask"
	flags_inv = HIDEFACE
	body_parts_covered = FACE|EYES

// Bandanas below
/obj/item/clothing/mask/bandana
	name = "black bandana"
	desc = "A bandana. Can be worn on the head or face."
	flags_inv = HIDEFACE
	slot_flags = SLOT_MASK|SLOT_HEAD
	body_parts_covered = FACE
	icon_state = "bandblack"
	item_state = "bandblack"
	item_flags = ITEM_FLAG_FLEXIBLEMATERIAL
	w_class = ITEM_SIZE_SMALL

/obj/item/clothing/mask/bandana/equipped(var/mob/user, var/slot)
	switch(slot)
		if(slot_wear_mask) //Mask is the default for all the settings
			flags_inv = initial(flags_inv)
			body_parts_covered = initial(body_parts_covered)
			icon_state = initial(icon_state)
		if(slot_head)
			flags_inv = 0
			body_parts_covered = HEAD
			icon_state = "[initial(icon_state)]_up"
	return ..()

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"
	item_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"
	item_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"
	item_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"
	item_state = "bandgold"

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	icon_state = "bandorange"
	item_state = "bandorange"

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	icon_state = "bandpurple"
	item_state = "bandpurple"
