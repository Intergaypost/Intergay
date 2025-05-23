/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/proc/is_damageable(var/additional_damage = 0)
	//Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	return ((robotic >= ORGAN_ROBOT) || brute_dam + burn_dam + additional_damage < max_damage * 4)

obj/item/organ/external/take_general_damage(var/amount, var/silent = FALSE)
	take_external_damage(amount)

/obj/item/organ/external/proc/take_external_damage(brute, burn, damage_flags, used_weapon = null)
	brute = round(brute * brute_mod, 0.1)
	burn = round(burn * burn_mod, 0.1)
	if((brute <= 0) && (burn <= 0))
		return 0

	var/sharp = (damage_flags & DAM_SHARP)
	var/edge  = (damage_flags & DAM_EDGE)
	var/laser = (damage_flags & DAM_LASER)
	var/blunt = brute && !sharp && !edge

	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)
	var/spillover = 0
	var/pure_brute = brute
	if(!is_damageable(brute + burn))
		spillover =  brute_dam + burn_dam + brute - max_damage
		if(spillover > 0)
			brute -= spillover
		else
			spillover = brute_dam + burn_dam + brute + burn - max_damage
			if(spillover > 0)
				burn -= spillover

	owner.updatehealth() //droplimb will call updatehealth() again if it does end up being called
	//If limb took enough damage, try to cut or tear it off
	if(owner && loc == owner && !is_stump())
		if(!cannot_amputate && config.limbs_can_break)
			var/statht = owner.stats[STAT_HT] * 10
			var/instance = 0
			var/instonce = 0
			instance = brute_dam - instance
			instonce = burn_dam - instonce
			var/force_droplimb = 0
			var/force_droplimbburn = 0
			if(instance >= statht)
				force_droplimb = 1
			if(instonce >= statht)
				force_droplimbburn = 1
			brute = pure_brute
			//to_chat(world, brute)
			if(edge && brute >= 60 / DROPLIMB_THRESHOLD_EDGE)
				if(prob(brute) || force_droplimb)
					droplimb(0, DROPLIMB_EDGE)
					return
			if(brute_dam >= (100 + statht))
				if(edge)
					droplimb(0, DROPLIMB_EDGE)
				else
					droplimb(0, DROPLIMB_BLUNT)
			if(burn_dam >= (100 + statht))
				droplimb(0, DROPLIMB_BURN)
			if(force_droplimb)
				droplimb(0, DROPLIMB_BLUNT)
			if(force_droplimbburn)
				droplimb(0, DROPLIMB_BURN)

	// High brute damage or sharp objects may damage internal organs
	var/damage_amt = brute
	var/cur_damage = brute_dam
	if(laser)
		damage_amt += burn
		cur_damage += burn_dam
	if(internal_organs && internal_organs.len && (cur_damage + damage_amt >= max_damage || (((sharp && damage_amt >= 5) || damage_amt >= 10) && prob(5))))
		// Damage an internal organ
		var/list/victims = list()
		for(var/obj/item/organ/internal/I in internal_organs)
			if(I.damage < I.max_damage && prob(I.relative_size))
				victims += I
		if(!victims.len)
			victims += pick(internal_organs)
		for(var/v in victims)
			var/obj/item/organ/internal/victim = v
			brute /= 2
			if(laser)
				burn /= 2
			damage_amt /= 2
			victim.take_internal_damage(damage_amt)

	if(status & ORGAN_BROKEN && brute)
		jostle_bone(brute)
		if(can_feel_pain() && prob(40))
			owner.emote("scream")	//getting hit on broken hand hurts

	if(brute_dam > min_broken_damage && prob(brute_dam + brute * (1+blunt)) ) //blunt damage is gud at fracturing
		fracture()

	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	var/datum/wound/created_wound
	var/block_cut = (species.species_flags & SPECIES_FLAG_NO_MINOR_CUT) && brute <= 15
	var/can_cut = !block_cut && robotic < ORGAN_ROBOT && (sharp || prob(brute))

	if(brute)
		var/to_create = BRUISE
		if(can_cut)
			to_create = CUT
			//need to check sharp again here so that blunt damage that was strong enough to break skin doesn't give puncture wounds
			if(sharp && !edge)
				to_create = PIERCE
		created_wound = createwound(to_create, brute)

	if(burn)
		if(laser)
			createwound(LASER, burn)
			if(prob(40))
				owner.IgniteMob()
		else
			createwound(BURN, burn)

	adjust_pain(0.9*burn + 0.6*brute)
	//If there are still hurties to dispense
	if (spillover)
		owner.shock_stage += spillover * config.organ_damage_spillover_multiplier

	// sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	if(owner && update_damstate())
		owner.UpdateDamageIcon()
		owner.update_bleeding()

	return created_wound

/obj/item/organ/external/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(robotic >= ORGAN_ROBOT && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == BURN && (burn_ratio < 1 || vital))
			burn = W.heal_damage(burn)
		else if(brute_ratio < 1 || vital)
			brute = W.heal_damage(brute)

	if(internal)
		status &= ~ORGAN_BROKEN

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	return update_damstate()

// Brute/burn
/obj/item/organ/external/proc/get_brute_damage()
	return brute_dam

/obj/item/organ/external/proc/get_burn_damage()
	return burn_dam

// Geneloss/cloneloss.
/obj/item/organ/external/proc/get_genetic_damage()
	return ((species && (species.species_flags & SPECIES_FLAG_NO_SCAN)) || robotic >= ORGAN_ROBOT) ? 0 : genetic_degradation

/obj/item/organ/external/proc/remove_genetic_damage(var/amount)
	if((species.species_flags & SPECIES_FLAG_NO_SCAN) || robotic >= ORGAN_ROBOT)
		genetic_degradation = 0
		status &= ~ORGAN_MUTATED
		return
	var/last_gene_dam = genetic_degradation
	genetic_degradation = min(100,max(0,genetic_degradation - amount))
	if(genetic_degradation <= 30)
		if(status & ORGAN_MUTATED)
			unmutate()
			to_chat(src, "<span class = 'notice'>Your [name] is shaped normally again.</span>")
	return -(genetic_degradation - last_gene_dam)

/obj/item/organ/external/proc/add_genetic_damage(var/amount)
	if((species.species_flags & SPECIES_FLAG_NO_SCAN) || robotic >= ORGAN_ROBOT)
		genetic_degradation = 0
		status &= ~ORGAN_MUTATED
		return
	var/last_gene_dam = genetic_degradation
	genetic_degradation = min(100,max(0,genetic_degradation + amount))
	if(genetic_degradation > 30)
		if(!(status & ORGAN_MUTATED) && prob(genetic_degradation))
			mutate()
			to_chat(owner, "<span class = 'notice'>Something is not right with your [name]...</span>")
	return (genetic_degradation - last_gene_dam)

/obj/item/organ/external/proc/mutate()
	if(src.robotic >= ORGAN_ROBOT)
		return
	src.status |= ORGAN_MUTATED
	if(owner) owner.update_body()

/obj/item/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	if(owner) owner.update_body()

/obj/item/organ/external/proc/update_pain()
	if(!can_feel_pain())
		pain = 0
		full_pain = 0
		return

	if(pain)
		pain -= owner.lying ? 3 : 1
		pain = max(pain, 0)

	var/lasting_pain = 0
	if(is_broken())
		lasting_pain += 10
	else if(is_dislocated())
		lasting_pain += 5

	var/tox_dam = 0
	for(var/i in internal_organs)
		var/obj/item/organ/internal/I = i
		tox_dam += I.getToxLoss()

	full_pain = pain + lasting_pain + 0.7 * brute_dam + 0.8 * burn_dam + 0.3 * tox_dam + 0.5 * get_genetic_damage()

/obj/item/organ/external/proc/get_pain()
	return pain

/obj/item/organ/external/proc/get_full_pain()
	return full_pain

/obj/item/organ/external/proc/adjust_pain(change)
	if(!can_feel_pain())
		return 0
	var/last_pain = pain
	pain = max(0, min(max_damage, pain + change))

	if(change > 0 && owner)
		if((change > 15 && prob(20)) || (change > 30 && prob(60)))
			owner.emote("scream")

	return pain - last_pain

/obj/item/organ/external/proc/remove_all_pain()
	pain = 0
	full_pain = 0

/obj/item/organ/external/proc/stun_act(var/stun_amount, var/agony_amount)
	if(agony_amount > 10 && owner && vital && get_full_pain() > 0.5 * max_damage)
		owner.visible_message("<span class='warning'>[owner] reels in pain!</span>")
		if(has_genitals() || get_full_pain() + agony_amount > max_damage)
			owner.Weaken(6)
		else
			owner.Stun(6)
			owner.drop_l_hand()
			owner.drop_r_hand()
		return 1

/obj/item/organ/external/proc/get_agony_multiplier()
	return has_genitals() ? 2 : 1

/obj/item/organ/external/proc/sever_artery()
	if(species && species.has_organ[BP_HEART])
		var/obj/item/organ/internal/heart/O = species.has_organ[BP_HEART]
		if(robotic < ORGAN_ROBOT && !(status & ORGAN_ARTERY_CUT) && !initial(O.open))
			status |= ORGAN_ARTERY_CUT
			if(artery_name == "cartoid artery")
				var/sound = list('sound/effects/gore/throat.ogg', 'sound/effects/gore/throat2.ogg', 'sound/effects/gore/throat3.ogg')
				playsound(owner.loc, 'sound/effects/gore/blood_splat.ogg', 100, 0)
				playsound(owner.loc, pick(sound), 50, 1, -1)
			else
				playsound(owner.loc, 'sound/effects/gore/blood_splat.ogg', 100, 0)
			return TRUE
	return FALSE

/obj/item/organ/external/proc/sever_tendon()
	if(has_tendon && robotic < ORGAN_ROBOT && !(status & ORGAN_TENDON_CUT))
		status |= ORGAN_TENDON_CUT
		return TRUE
	return FALSE

/obj/item/organ/external/proc/get_fingers()
	var/amt = 0
	if(!fingers.len)
		return 0
	for(var/i = 0; i < fingers.len; i++)
		amt++

	return amt

/obj/item/organ/external/proc/get_broken_fingers()
	var/amt = 0
	if(!fingers.len)
		return 0
	for(var/obj/item/organ/finger/F in fingers)
		if(F.state == "BROKEN")
			amt++

	return amt

/obj/item/organ/external/proc/get_lost_fingers_number()
	var/amt = 0
	if(!fingers.len)
		return 5

	for(var/x in digit_check)
		var/test = 1
		for(var/obj/item/organ/finger/F in fingers)
			if(F.name != x)
				test = 0
				continue
			test = 1
			break
		if(!test)
			amt ++
	return amt

/obj/item/organ/external/proc/get_lost_fingers_text()
	var/list/amt = list()

	if(!fingers.len)
		return list("ALL FINGERS MISSING!")

	for(var/x in digit_check)
		var/test = 1
		for(var/obj/item/organ/finger/F in fingers)
			if(F.name != x)
				test = 0
				continue
			test = 1
			break
		if(!test)
			amt += x


	return amt

/obj/item/organ/external/proc/get_fucked_up()
	var/amt = list()

	if(!fingers.len)
		return list("<span class='missingnew'>ALL FINGERS MISSING!</span>")

	for(var/x in digit_check)
		var/test = 1
		for(var/obj/item/organ/finger/F in fingers)
			if(F.name != x)
				test = 0
				continue
			test = 1
			break

		if(!test)
			amt += "<span class='missingnew'><big>[uppertext(x)] MISSING</big></span>"

	for(var/obj/item/organ/finger/F in fingers)
		if(F.state == "BROKEN")
			amt += "<span class='missingnew'><big>[uppertext(F.name)] BROKEN</big></span>"

	return amt

/obj/item/organ/external/proc/ripout_fingers(throw_dir, num=32) //Won't support knocking teeth out of a dismembered head or anything like that yet.
	num = Clamp(num, 1, 32)
	var/done = 0
	if(fingers && fingers.len) //We still have teeth
		var/lostfingers = rand(1,3)
		for(var/i, i <= lostfingers, i++) //Random amount of teeth stacks
			var/obj/item/organ/finger/F = pick(fingers)
			fingers -= F
			playsound(owner, "chop", 50, 1, -1)
			owner.visible_message("<span class='graytextbold'> [capitalize(owner.name)]'s [F] flies off in bloody arc!</span> ")
			F.loc = owner.loc
			var/turf/target = get_turf(owner.loc)
			var/range = rand(1, 3)
			for(var/j = 1; j < range; j++)
				var/turf/new_turf = get_step(target, throw_dir)
				target = new_turf
				if(new_turf.density)
					break
			F.throw_at(get_edge_target_turf(F,pick(GLOB.alldirs)),rand(1,3),30)
			F.loc:add_blood(owner)
			done = 1
	return done