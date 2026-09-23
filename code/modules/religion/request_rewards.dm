/*  
	Requests are weird.
	Basically each request is "fufilled" by praying somehow.  Examples: Pray in public.  Place required items around shrine then pray.  Kill a specific player, then praise_god  
	The important thing is prayer is the trigger for a request to be fufilled.  This way, all prayer has to do is call "is_fufilled" for the current request
	And all types should be handled.
*/

/datum/request/
	var/name
	var/message //Message that gets sent when the player is sent the request
	var/satisfied = FALSE //If the request is satisfied or not

/datum/request/proc/check_complete(var/mob/living/target)
	return

//Declare feality to your god in the public's eyes
/datum/request/public_prayer/
	name ="Public Prayer"
	message = "Pronounce your loyalty in public, for all to hear!"

/datum/request/public_prayer/check_complete(var/mob/living/target)
	for(var/mob/living/M in view(target, 8))
		if(M.religion == LEGAL_RELIGION)
			return 1
	return 0

/datum/request/offering/
	name ="Offering"
	message = "Your god demands an offering!"
	var/offering_item

/datum/request/offering/New(var/religion)
	var/datum/religion/rel = GLOB.all_religions[religion]
	if(rel)
		offering_item = pick(rel.offering_items)
		offering_item = new offering_item
	message += "   Place \the [offering_item] before a shrine and praise your god."

/datum/request/offering/check_complete(var/mob/living/target)
	for(var/obj/O in view(target, 5))
		if(istype(O,offering_item))
			qdel(O)
			return 1
	return 0

/*	Rewards get defined individually with thier own special verb
	All reward code should be self contained.  All the actual "reward" function will do is
	pick a reward and run it's verb
*/
/datum/reward/
	var/name = null
	var/message = null

/datum/reward/proc/do_reward()
	to_world("You should not be seeing this!")
	
/datum/reward/money
	name = "Money" //LOADSA EMONE
	message="You have been graced with a bonus!"

/datum/reward/money/do_reward(var/mob/living/target)
	for(var/datum/money_account/acounts in all_money_accounts)
		if(acounts.owner_name == target.name)
			var/datum/transaction/T = new("[target.religion]", "Request fufilled", 1000)
			to_chat(target, message)
			playsound(target, 'sound/effects/phone_ring.ogg', 25, 1, -1)
			acounts.do_transaction(T)

/datum/reward/happiness/
	name = "Happiness"
	message="You feel a soothing calm settle on your soul."

/datum/reward/happiness/do_reward(var/mob/living/carbon/human/target)
	to_chat(target, message)
	target.add_event("fulfilled request", /datum/happiness_event/request_fulfilled)

/datum/reward/str_up/
	name = "Strength blessing"
	message="You feel an incredible power rising within you."

/datum/reward/str_up/do_reward(var/mob/living/target)
	var/initial = target.stats[STAT_ST] 
	to_chat(target, message)
	target.stats[STAT_ST] = 20
	spawn(1200)
		target.stats[STAT_ST] = initial


/*	 Punishmentss are basically rewards but bad.
*/
/datum/punishment/
	var/name = null
	var/message = null

datum/punishment/proc/do_punishment()
	to_world("You should not be seeing this!")
	
datum/punishment/money
	name = "Money" //LOADSA EMONE
	message="Your wages have been garnished..."

datum/punishment/money/do_punishment(var/mob/living/target)
	for(var/datum/money_account/acounts in all_money_accounts)
		if(acounts.owner_name == target.name)
			var/datum/transaction/T = new("[target.religion]", "Request failed", -1000)
			to_chat(target, message)
			var/L = target.loc
			playsound(L, 'sound/effects/phone_ring.ogg', 50, 1, -1)
			acounts.do_transaction(T)

datum/punishment/happiness/
	name = "Happiness"
	message="You feel a great sense of unrest."

datum/punishment/happiness/do_punishment(var/mob/living/carbon/human/target)
	to_chat(target, message)
	target.add_event("Disapointed god", /datum/happiness_event/request_failed)

datum/punishment/str_up/
	name = "Strength blessing"
	message="You feel a terrible weakness in your body."

datum/punishment/str_up/do_punishment(var/mob/living/target)
	var/initial = target.stats[STAT_ST] 
	to_chat(target, message)
	target.stats[STAT_ST] = 2
	spawn(1200)
		target.stats[STAT_ST] = initial
