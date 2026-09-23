/decl/hierarchy/outfit/job/security
	hierarchy_type = /decl/hierarchy/outfit/job/security

/decl/hierarchy/outfit/job/security/New()
	..()
	BACKPACK_OVERRIDE_SECURITY

/decl/hierarchy/outfit/job/security/hos
	name = OUTFIT_JOB_NAME("Head of security")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/security/head
	pda_type = /obj/item/device/pda/heads/hos

/decl/hierarchy/outfit/job/security/warden
	name = OUTFIT_JOB_NAME("Warden")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/security/warden
	pda_type = /obj/item/device/pda/warden

/decl/hierarchy/outfit/job/security/detective
	name = OUTFIT_JOB_NAME("Detective")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/security/detective
	pda_type = /obj/item/device/pda/detective
	backpack_contents = list(/obj/item/weapon/storage/box/evidence = 1)

/decl/hierarchy/outfit/job/security/detective/New()
	..()
	backpack_overrides.Cut()

/decl/hierarchy/outfit/job/security/detective/forensic
	name = OUTFIT_JOB_NAME("Forensic technician")
	head = null
	suit = /obj/item/clothing/suit/storage/forensics/blue

/decl/hierarchy/outfit/job/security/officer
	name = OUTFIT_JOB_NAME("Security Officer")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/security
	pda_type = /obj/item/device/pda/security

/*
/decl/hierarchy/outfit/job/security/officer/post_equip(var/mob/living/carbon/human/H)
	..()
	// Since we can have something other than the default uniform at this
	// point, check if we can actually attach the medal
	var/obj/item/clothing/uniform = H.w_uniform
	if(uniform)
	var/obj/item/clothing/accessory/storage/Lifchik = new()
		if(uniform.can_attach_accessory(Lifchik))
			uniform.attach_accessory(null, Lifchik)
		else
			qdel(Lifchik)
*/

/decl/hierarchy/outfit/job/security/arbiter
	name = OUTFIT_JOB_NAME("Arbiter")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/arbiter
	pda_type = /obj/item/device/pda