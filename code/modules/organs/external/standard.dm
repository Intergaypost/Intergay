/****************************************************
			   ORGAN DEFINES
****************************************************/

//Make sure that w_class is set as if the parent mob was medium sized! This is because w_class is adjusted automatically for mob_size in New()

/obj/item/organ/external/chest
	name = "upper body"
	organ_tag = BP_CHEST
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	base_miss_chance = 10
	w_class = ITEM_SIZE_HUGE //Used for dismembering thresholds, in addition to storage. Humans are w_class 6, so it makes sense that chest is w_class 5.
	body_part = UPPER_TORSO
	vital = 1
	amputation_point = "spine"
	joint = "neck"
	dislocated = -1
	gendered_icon = 1
	cannot_amputate = 1
	parent_organ = null
	encased = "ribcage"
	artery_name = "aorta"
	cavity_name = "thoracic"
	var/butchering_capacity = 1

/obj/item/organ/external/chest/robotize()
	if(..())
		// Give them a new cell.
		var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
		if(!istype(C))
			owner.internal_organs_by_name[BP_CELL] = new /obj/item/organ/internal/cell(owner,1)

/obj/item/organ/external/get_scan_results()
	. = ..()
	var/obj/item/organ/internal/lungs/L = locate() in src
	if( L && L.is_bruised())
		. += "Lung ruptured"

/obj/item/organ/external/groin
	name = "lower body"
	organ_tag = BP_GROIN
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	base_miss_chance = 10
	w_class = ITEM_SIZE_LARGE
	body_part = LOWER_TORSO
	vital = 1
	parent_organ = BP_CHEST
	amputation_point = "lumbar"
	joint = "hip"
	dislocated = -1
	gendered_icon = 1
	artery_name = "iliac artery"
	cavity_name = "abdominal"

/obj/item/organ/external/groin/droplimb(var/clean, var/disintegrate = DROPLIMB_EDGE, var/ignore_children, var/silen)
	if(owner.has_penis())//Instead of bisecting them entirely just fucking drop their dick off.
		owner.mutilate_genitals()
		owner.visible_message("<span class='danger'><big>\The [owner]'s penis flies off in a bloody arc!</big></span>")
		playsound(owner, 'sound/effects/gore/severed.ogg', 50, 1, -1)
		new /obj/item/organ/internal/penis(owner.loc)

/obj/item/organ/external/arm
	organ_tag = BP_L_ARM
	name = "left arm"
	icon_name = "l_arm"
	max_damage = 50
	min_broken_damage = 30
	base_miss_chance = 10
	w_class = ITEM_SIZE_NORMAL
	body_part = ARM_LEFT
	parent_organ = BP_CHEST
	joint = "left elbow"
	amputation_point = "left shoulder"
	can_grasp = 1
	has_tendon = TRUE
	tendon_name = "palmaris longus tendon"
	artery_name = "basilic vein"
	arterial_bleed_severity = 0.75
	gendered_icon = 1

/obj/item/organ/external/arm/stun_act(var/stun_amount, var/agony_amount)
	if(!owner || (agony_amount < 5))
		return
	if(prob(25))
		owner.grasp_damage_disarm(src)

/obj/item/organ/external/arm/right
	organ_tag = BP_R_ARM
	name = "right arm"
	icon_name = "r_arm"
	body_part = ARM_RIGHT
	joint = "right elbow"
	amputation_point = "right shoulder"

/obj/item/organ/external/leg
	organ_tag = BP_L_LEG
	name = "left leg"
	icon_name = "l_leg"
	max_damage = 50
	min_broken_damage = 30
	base_miss_chance = 10
	w_class = ITEM_SIZE_NORMAL
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = BP_GROIN
	joint = "left knee"
	amputation_point = "left hip"
	can_stand = 1
	has_tendon = TRUE
	tendon_name = "cruciate ligament"
	artery_name = "femoral artery"
	arterial_bleed_severity = 0.75
	gendered_icon = 1

/obj/item/organ/external/leg/stun_act(var/stun_amount, var/agony_amount)
	if(!owner || agony_amount < 5)
		return
	if(prob(min(agony_amount*2,50)))
		to_chat(owner, "<span class='warning'>Your [src] buckles from the shock!</span>")
		owner.Weaken(5)

/obj/item/organ/external/leg/right
	organ_tag = BP_R_LEG
	name = "right leg"
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT
	joint = "right knee"
	amputation_point = "right hip"

/obj/item/organ/external/foot
	organ_tag = BP_L_FOOT
	name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 15
	base_miss_chance = 30
	w_class = ITEM_SIZE_SMALL
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = BP_L_LEG
	joint = "left ankle"
	amputation_point = "left ankle"
	can_stand = 1
	has_finger = 1
	has_tendon = 1
	tendon_name = "Achilles tendon"
	arterial_bleed_severity = 0.5
	gendered_icon = 1
	digit_check = list("big toe", "index toe", "middle toe" , "ring toe" , "little toe")

/obj/item/organ/external/foot/stun_act(var/stun_amount, var/agony_amount)
	if(!owner || agony_amount < 5)
		return
	if(prob(min(agony_amount*4,70)))
		to_chat(owner, "<span class='warning'>You lose your footing as your [src] spasms!</span>")
		owner.Weaken(5)

/obj/item/organ/external/foot/removed()
	if(owner) owner.drop_from_inventory(owner.shoes)
	..()

/obj/item/organ/external/foot/right
	organ_tag = BP_R_FOOT
	name = "right foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	has_finger = TRUE
	parent_organ = BP_R_LEG
	joint = "right ankle"
	amputation_point = "right ankle"

/obj/item/organ/external/hand
	organ_tag = BP_L_HAND
	name = "left hand"
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 15
	base_miss_chance = 20
	w_class = ITEM_SIZE_SMALL
	body_part = HAND_LEFT
	parent_organ = BP_L_ARM
	joint = "left wrist"
	amputation_point = "left wrist"
	can_grasp = 1
	has_tendon = 1
	has_finger = 1
	tendon_name = "carpal ligament"
	arterial_bleed_severity = 0.5
	gendered_icon = 1
	digit_check = list("thumb", "index finger", "middle finger", "ring finger", "little finger")

/obj/item/organ/external/hand/stun_act(var/stun_amount, var/agony_amount)
	if(!owner || (agony_amount < 5))
		return
	owner.grasp_damage_disarm(src)

/obj/item/organ/external/hand/removed()
	owner.drop_from_inventory(owner.gloves)
	..()

/obj/item/organ/external/hand/right
	organ_tag = BP_R_HAND
	name = "right hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT
	parent_organ = BP_R_ARM
	has_finger = 1
	joint = "right wrist"
	amputation_point = "right wrist"

/obj/item/organ/finger
	var/nail = 1
	var/state = "OK" // OK, BROKEN

//dedos normais

/obj/item/organ/finger/thumb
	name = "thumb"
	icon_state = "finger3"

/obj/item/organ/finger/index
	name = "index finger"
	icon_state = "finger1"

/obj/item/organ/finger/middle
	name = "middle finger"
	icon_state = "finger2"

/obj/item/organ/finger/ring
	name = "ring finger"
	icon_state = "finger3"

/obj/item/organ/finger/little
	name = "little finger"
	icon_state = "sfinger1"

//dedao do pe

/obj/item/organ/finger/big_toe
	name = "big toe"
	icon_state = "finger3"

/obj/item/organ/finger/index_toe
	name = "index toe"
	icon_state = "finger1"

/obj/item/organ/finger/middle_toe
	name = "middle toe"
	icon_state = "finger2"

/obj/item/organ/finger/ring_toe
	name = "ring toe"
	icon_state = "finger3"

/obj/item/organ/finger/little_toe
	name = "little toe"
	icon_state = "sfinger1"
