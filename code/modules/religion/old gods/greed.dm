/datum/religion/greed
	name = GREED
	holy_item = new /obj/item/weapon/coin/gold()
	shrine = /obj/old_god_shrine/greed_shrine
	var/bloodgold = FALSE
	whisper_lines = list("Money is time.", "Invest wisely.", "It can't go tits up.")
	offering_items = list(/obj/item/weapon/spacecash/bundle/c100, /obj/item/stack/material/gold/ten, /obj/item/stack/material/silver/ten)

/datum/religion/greed/generate_random_phrase()
		var/phrase = pick("Oh great [name] ", "Oh [name]. ", "[name], our Benefactor. ")
		phrase += pick("You enrich our lives ", "You will shower us with gold ", "You bathe our [pick("outpost","kingdom","cities")] in your opulence. ")
		phrase += pick("In your golden light ", "[name] enrish us all. ", "[name] fill our pockets. ")
		phrase += "Amen"
		return phrase

/datum/old_god_spell/debt
	name = "Debt"
	requirments =  list("SOUTH" = /obj/item/weapon/handcuffs,
						"SOUTHEAST" = /obj/item/weapon/paper,
						"SOUTHWEST" = /obj/item/weapon/paper)
	old_god = GREED

	spell_effect(var/mob/living/user, var/list/spell_components)
		var/obj/item/weapon/paper/target1_paper = spell_components["SOUTHWEST"]
		var/obj/item/weapon/paper/target2_paper = spell_components["SOUTHEAST"]
		var/mob/target1 = get_player_from_paper(target1_paper)
		var/mob/target2 = get_player_from_paper(target2_paper)
		if(target1 && target2)
			var/L = target1.loc
			new /obj/item/weapon/paper/contract/debt/(L, user,  target1, target2)
			playsound(L, 'sound/effects/phone_ring.ogg', 50, 1, -1)

/datum/old_god_spell/blood_gold
	name = "Blood Gold"
	requirments =  list("NORTHEAST" = /obj/item/weapon/spacecash/bundle/,
						"NORTHWEST" = /obj/item/weapon/spacecash/bundle/,
						"SOUTHEAST" = /obj/item/weapon/spacecash/bundle/,
						"SOUTHWEST" = /obj/item/weapon/spacecash/bundle/,
						"NORTH" = /obj/effect/decal/cleanable/blood/,
						"WEST" = /obj/effect/decal/cleanable/blood/,
						"SOUTH" = /obj/effect/decal/cleanable/blood/,
						"EAST" = /obj/effect/decal/cleanable/blood/)
	old_god = GREED

	spell_effect(var/mob/living/user)
		to_chat(user, "<span class='danger'>You hear a sinister voice, whispering unspeakable acts in your mind...promising untold profits.</span>")
		var/sound = "sound/effects/badmood[pick(1,4)].ogg"
		playsound(get_turf(user), sound,50,1)
		var/datum/religion/greed/R = GLOB.all_religions[GREED]
		if(R) R.bloodgold = TRUE
		spawn(600) //30 seconds
			if(R) R.bloodgold = FALSE

/obj/old_god_shrine/greed_shrine
	name = "gold-plated shrine"
	shrine_religion = GREED
	icon_state = "greed"
	var/spell_to_blood = FALSE

/obj/old_god_shrine/greed_shrine/New()
	..()
	shrine_religion = GLOB.all_religions[GREED]


/*
Debt contract
*/
/obj/item/weapon/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = FALSE
	var/datum/mind/target
	info = "test"
	item_flags = ITEM_FLAG_NO_BLUDGEON

/obj/item/weapon/paper/contract/proc/update_text()
	return

/obj/item/weapon/paper/contract/debt
	icon_state = "paper_words"

/obj/item/weapon/paper/contract/debt/New(atom/loc, mob/living/nOwner, var/mob/target1, var/mob/target2)
	. = ..()
	if(!nOwner || !nOwner.mind)
		qdel(src)
		return -1
	target = nOwner.mind
	update_text(target1,target2)
	spawn(3000)  //Should be 5 minutes
		for(var/datum/money_account/acounts in all_money_accounts)
			if(acounts.owner_name == target2.name)
				for(var/datum/transaction/T in acounts.transaction_log)
					if(T.target_name == target1.name)
						return
		for(var/mob/living/carbon/human/gore_target in GLOB.player_list)
			if(gore_target.name == target1.name)
				var/obj/item/organ/external/E = pick(gore_target.organs)
				E.droplimb(0, DROPLIMB_EDGE)


/obj/item/weapon/paper/contract/debt/update_text(var/mob/target1, var/mob/target2)
	name = "paper- [target] employment contract"
	to_world("These are our vars [target1], [target2]")
	info = "<center>NOTICE OF DEBT</center><BR>This letter is to inform you <bold>([target1.name])</bold> of a debt issued to your account, either by death of a relative or other means.  A claim has been places on your account for 1000 credits payed in full to <bold>[target2]</bold> Account Number: <bold>[target2.mind.initial_account.account_number]</bold> within the next 5 minutes.  Failure to do so will result in collection through alternative means. <BR>Sincerely, <BR> Gozag Ym Sagoz Banking"