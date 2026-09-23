/obj/item/weapon/key/locker_key
	name = "locker key"
	desc = "A small metallic key for a personal storage locker. Keep it safe."
	icon = 'icons/obj/items.dmi'
	icon_state = "keys"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_POCKET | SLOT_AMULET | SLOT_TIE
	var/owner_ckey = null
	var/owner_name = null
	var/locker_tag = null

/obj/item/weapon/key/locker_key/New(var/newloc, var/data, var/tag_num, var/char_name, var/ckey_val)
	if(!isnull(tag_num) && tag_num > 0)
		locker_tag = tag_num
		name = "locker key #[locker_tag]"
	if(char_name)
		owner_name = char_name
	if(ckey_val)
		owner_ckey = ckey_val
	if(data)
		key_data = data
	else if(!key_data)
		key_data = generateRandomString(8)
	..(newloc, key_data)

/obj/item/weapon/key/locker_key/examine(mob/user)
	..(user)
	if(locker_tag)
		to_chat(user, "<span class='notice'>The tag reads: 'Locker #[locker_tag]'.</span>")
	if(owner_name)
		to_chat(user, "<span class='notice'>There is an engraving with the name '[owner_name]'.</span>")
