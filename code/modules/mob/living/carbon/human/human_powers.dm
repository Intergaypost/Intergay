	// These should all be procs, you can add them to humans/subspecies by
// species.dm's inherent_verbs ~ Z

/mob/living/carbon/human/proc/tackle()
	set category = "Abilities"
	set name = "Tackle"
	set desc = "Tackle someone down."

	if(last_special > world.time)
		return

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len)
		to_chat(src, "<span class='warning'>You cannot tackle in your current state.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/M in view(1,src))
		if(!istype(M,/mob/living/silicon) && Adjacent(M))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to tackle?") as null|anything in choices

	if(!T || !src || src.stat) return

	if(!Adjacent(T)) return

	//check again because we waited for user input
	if(last_special > world.time)
		return

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len)
		to_chat(src, "<span class='warning'>You cannot tackle in your current state.</span>")
		return

	last_special = world.time + 50

	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
	T.Weaken(rand(1,3))
	if(prob(75))
		visible_message("<span class='danger'>\The [src] has tackled down [T]!</span>")
	else
		visible_message("<span class='danger'>\The [src] tried to tackle down [T]!</span>")
		src.Weaken(rand(2,4)) //failure, you both get knocked down

/mob/living/carbon/human/proc/leap()
	set category = "Abilities"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	if(last_special > world.time)
		return

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len)
		to_chat(src, "<span class='warning'>You cannot leap in your current state.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/M in oview(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") as null|anything in choices

	if(!T || !isturf(T.loc) || !src || !isturf(loc)) return

	if(get_dist(get_turf(T), get_turf(src)) > 4) return

	//check again because we waited for user input
	if(last_special > world.time)
		return

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len || stance_damage >= 4)
		to_chat(src, "<span class='warning'>You cannot leap in your current state.</span>")
		return

	playsound(src.loc, 'sound/voice/shriek1.ogg', 50, 1)

	last_special = world.time + (17.5 SECONDS)
	status_flags |= LEAPING

	src.visible_message("<span class='danger'>\The [src] leaps at [T]!</span>")
	src.throw_at(get_step(get_turf(T),get_turf(src)), 4, 1, src)

	sleep(5)

	if(status_flags & LEAPING) status_flags &= ~LEAPING

	if(!src.Adjacent(T))
		to_chat(src, "<span class='warning'>You miss!</span>")
		return

	T.Weaken(3)

	if(src.make_grab(src, T))
		src.visible_message("<span class='warning'><b>\The [src]</b> seizes [T]!</span>")

/mob/living/carbon/human/proc/commune()
	set category = "Abilities"
	set name = "Commune with creature"
	set desc = "Send a telepathic message to an unlucky recipient."

	var/list/targets = list()
	var/target = null
	var/text = null

	targets += getmobs() //Fill list, prompt user with list
	target = input("Select a creature!", "Speak to creature", null, null) as null|anything in targets

	if(!target) return

	text = input("What would you like to say?", "Speak to creature", null, null)

	text = sanitize(text)

	if(!text) return

	var/mob/M = targets[target]

	if(isghost(M) || M.stat == DEAD)
		to_chat(src, "<span class='warning'>Not even a [src.species.name] can speak to the dead.</span>")
		return

	log_and_message_admins("[key_name(src)] communed and used psychic whisper to [key_name(M)]: [text]")

	to_chat(M, "<span class='notice'>Like lead slabs crashing into the ocean, alien thoughts drop into your mind: <i>[text]</i></span>")
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.species.name == src.species.name)
			return
		if(prob(75))
			to_chat(H, "<span class='warning'>Your nose begins to bleed...</span>")
			H.drip(1)

/mob/living/carbon/human/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Abilities"

	var/obj/item/organ/internal/stomach/stomach = internal_organs_by_name[BP_STOMACH]
	if(stomach && stomach.contents.len)
		for(var/atom/movable/M in stomach.contents)
			M.dropInto(loc)
		var/datum/gender/G = gender_datums[gender]
		visible_message(SPAN_DANGER("\The [src] hurls up the contents of [G.his] stomach!"))
		return
	visible_message(SPAN_DANGER("\The [src] dry-heaves!"))

/mob/living/carbon/human/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Abilities"

	if(stat != CONSCIOUS || disrupts_psionics()) //Do not use it while unconscious or disrupted.
		to_chat(src, "<span class='warning'>You can't focus enough to do this!</span>")
		return

	if(isghost(M) || M.stat == DEAD)
		to_chat(src, "<span class='warning'>You cannot speak to the dead.</span>")
		return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_and_message_admins("PsychicWhisper: [key_name(src)]->[M.key] : [msg]")
		to_chat(M, "<span class='alium'>You hear a strange, alien voice in your head... <i>[msg]</i></span>")
		to_chat(src, "<span class='alium'>You channel a message: \"[msg]\" to [M]</span>")
	return

/mob/living/carbon/human/proc/can_nab(var/mob/living/target)
	if(QDELETED(src))
		return FALSE

	if(last_special > world.time)
		to_chat(src, "<span class='warning'>It is too soon to make another nab attempt.</span>")
		return FALSE

	if(incapacitated())
		to_chat(src, "<span class='warning'>You cannot nab in your current state.</span>")
		return FALSE

	if(!is_cloaked() || pulling_punches)
		to_chat(src, "<span class='warning'>You can only nab people when you are well hidden and ready to hunt.</span>")
		return FALSE

	if(target)
		if(!istype(target) || issilicon(target))
			return FALSE
		if(!Adjacent(target))
			to_chat(src, "<span class='warning'>\The [target] has to be adjacent to you.</span>")
			return FALSE

	return TRUE

/mob/living/carbon/human/proc/nab()
	set category = "Abilities"
	set name = "Nab"
	set desc = "Nab someone."

	if(!can_nab())
		return

	var/list/choices = list()
	for(var/mob/living/M in view(1,src))
		if(!istype(M,/mob/living/silicon) && Adjacent(M))
			choices += M
	choices -= src

	var/mob/living/T = input(src, "Who do you wish to nab?") as null|anything in choices
	if(!T || !can_nab(T))
		return

	last_special = world.time + 50

	if(l_hand) unEquip(l_hand)
	if(r_hand) unEquip(r_hand)
	to_chat(src, "<span class='warning'>You drop everything as you spring out to nab someone!.</span>")

	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
	remove_cloaking_source(species)

	if(prob(90) && src.make_grab(src, T, GRAB_NAB_SPECIAL))
		T.Weaken(rand(1,3))
		visible_message("<span class='danger'>\The [src] suddenly lunges out and grabs \the [T]!</span>")
		LAssailant = src

		src.do_attack_animation(T)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return 1

	else
		visible_message("<span class='danger'>\The [src] suddenly lunges out, almost grabbing \the [T]!</span>")

/mob/living/carbon/human/proc/active_camo()
	set category = "Abilities"
	set name = "Active Camo"
	set desc = "Camouflage yourself"

	if(is_cloaked_by(species))
		remove_cloaking_source(species)
	else
		add_cloaking_source(species)
		apply_effect(2, STUN, 0)

/mob/living/carbon/human/proc/switch_stance()
	set category = "Abilities"
	set name = "Switch Stance"
	set desc = "Toggle between your hunting and manipulation stance"

	if(stat) return

	to_chat(src, "<span class='notice'>You begin to adjust the fluids in your arms, dropping everything and getting ready to swap which set you're using.</span>")
	var/hidden = is_cloaked()
	if(!hidden)
		visible_message("[src] shifts \his arms.")

	if(l_hand) unEquip(l_hand)
	if(r_hand) unEquip(r_hand)

	if(do_after(src, 30))
		hidden = is_cloaked()
		pulling_punches = !pulling_punches
		nabbing = !pulling_punches

		if(pulling_punches)
			current_grab_type = all_grabobjects[GRAB_NORMAL]
			to_chat(src, "<span class='notice'>You relax your hunting arms, lowering the pressure and folding them tight to your thorax.\
			You reach out with your manipulation arms, ready to use complex items.</span>")
			if(!hidden)
				visible_message("<span class='notice'>[src] seems to relax as \he folds \his massive curved arms to \his thorax and reaches out \
				with \his small handlike limbs.</span>")
		else
			current_grab_type = all_grabobjects[GRAB_NAB]
			to_chat(src, "<span class='notice'>You pull in your manipulation arms, dropping any items and unfolding your massive hunting arms in preparation of grabbing prey.</span>")
			if(!hidden)
				visible_message("<span class='warning'>[src] tenses as \he brings \his smaller arms in close to \his body. \His two massive spiked arms reach \
				out. \He looks ready to attack.</span>")
	else
		to_chat(src, "<span class='notice'>You stop adjusting your arms and don't switch between them.</span>")

/mob/living/carbon/human/proc/change_colour()
	set category = "Abilities"
	set name = "Change Colour"
	set desc = "Choose the colour of your skin."

	var/new_skin = input(usr, "Choose your new skin colour: ", "Change Colour", rgb(r_skin, g_skin, b_skin)) as color|null
	change_skin_color(hex2num(copytext(new_skin, 2, 4)), hex2num(copytext(new_skin, 4, 6)), hex2num(copytext(new_skin, 6, 8)))

/mob/living/carbon/human/proc/threat_display()
	set category = "Abilities"
	set name = "Threat Display"
	set desc = "Toggle between scary or not."

	if(stat)
		to_chat(src, "<span class='warning'>You can't do a threat display in your current state.</span>")
		return

	switch(skin_state)
		if(SKIN_NORMAL)
			if(pulling_punches)
				to_chat(src, "<span class='warning'>You must be in your hunting stance to do a threat display.</span>")
				return
			var/message = alert("Would you like to show a scary message?",,"Cancel","Yes", "No")
			switch(message)
				if("Yes")
					visible_message("<span class='warning'>[src]'s skin shifts to a deep red colour with dark chevrons running down in an almost hypnotic \
						pattern. Standing tall, \he strikes, sharp spikes aimed at those threatening \him, claws whooshing through the air past them.</span>")
				if("Cancel")
					return
			playsound(src, 'sound/effects/angrybug.ogg', 60, 0)
			skin_state = SKIN_THREAT
			spawn(100)
				if(skin_state == SKIN_THREAT)
					skin_state = SKIN_NORMAL
					update_skin(1)
		if(SKIN_THREAT)
			skin_state = SKIN_NORMAL
	update_skin(1)

