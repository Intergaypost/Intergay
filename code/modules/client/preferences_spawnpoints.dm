GLOBAL_VAR(spawntypes)

/proc/spawntypes()
	if(!GLOB.spawntypes)
		GLOB.spawntypes = list()
		for(var/type in typesof(/datum/spawnpoint)-/datum/spawnpoint)
			var/datum/spawnpoint/S = type
			var/display_name = initial(S.display_name)
			if((display_name in GLOB.using_map.allowed_spawns) || initial(S.always_visible))
				GLOB.spawntypes[display_name] = new S
	return GLOB.spawntypes

/datum/spawnpoint
	var/msg		  //Message to display on the arrivals computer.
	var/list/turfs   //List of turfs to spawn on.
	var/display_name //Name used in preference setup.
	var/always_visible = FALSE	// Whether this spawn point is always visible in selection, ignoring map-specific settings.
	var/list/restrict_job = null
	var/list/disallow_job = null

/datum/spawnpoint/proc/check_job_spawning(var/job)
	if(restrict_job && !(job in restrict_job))
		return 0

	if(disallow_job && (job in disallow_job))
		return 0

	return 1

/datum/spawnpoint/proc/get_spawn_turfs(var/rank)
	return turfs

/datum/spawnpoint/proc/get_spawn_turf(var/rank)
	var/list/candidates = get_spawn_turfs(rank)
	if(candidates && candidates.len)
		return pick(candidates)
	if(turfs && turfs.len)
		return pick(turfs)
	return null

//Called after mob is created, moved to a turf and equipped.
/datum/spawnpoint/proc/after_join(var/mob/victim)
	return

#ifdef UNIT_TEST
/datum/spawnpoint/Del()
	crash_with("Spawn deleted: [log_info_line(src)]")
	..()

/datum/spawnpoint/Destroy()
	crash_with("Spawn destroyed: [log_info_line(src)]")
	. = ..()
#endif

/datum/spawnpoint/arrivals
	display_name = "Arrivals Shuttle"
	msg = "has arrived on the station"

/datum/spawnpoint/arrivals/New()
	..()
	turfs = GLOB.latejoin

/datum/spawnpoint/gateway
	display_name = "Gateway"
	msg = "has completed translation from offsite gateway"

/datum/spawnpoint/gateway/New()
	..()
	turfs = GLOB.latejoin_gateway

/datum/spawnpoint/cryo
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	disallow_job = list("Cyborg", "AI")

/datum/spawnpoint/cryo/New()
	..()
	turfs = GLOB.latejoin_cryo

/datum/spawnpoint/cryo/get_spawn_turfs(var/rank)
	var/list/dept_turfs
	switch(rank)
		if("Captain")
			dept_turfs = GLOB.latejoin_cryocaptain
		if("Executive Officer", "Head of Personnel")
			dept_turfs = GLOB.latejoin_cryohop
		if("Vessel Overseer", "Maintainer", "Chief Engineer", "Station Maintainer", "Station Engineer", "Atmospheric Technician")
			dept_turfs = GLOB.latejoin_cryoengineering
		if("Head Scientist", "General Researcher", "Research Director", "Scientist", "Xenobiologist", "Roboticist", "Robocist")
			dept_turfs = GLOB.latejoin_cryoscience
		if("Medical Officer", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Psychiatrist", "Paramedic", "Surgeon", "Practitioner", "Emergency physician", "Undertaker", "Medical Assistant")
			dept_turfs = GLOB.latejoin_cryomedical
		if("Major", "Enforcer", "Head of Security", "Warden", "Detective", "Security Officer", "Head Peacekeeper", "Peacekeeper", "Loyaler Enforcer")
			dept_turfs = GLOB.latejoin_cryosecurity

	if(dept_turfs && dept_turfs.len)
		return dept_turfs
	if(GLOB.latejoin_cryo && GLOB.latejoin_cryo.len)
		return GLOB.latejoin_cryo
	return turfs

/datum/spawnpoint/cryo/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			if(victim.mind && victim.mind.assigned_role == "Captain")
				addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_captain_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
				addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), 24 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			else if(victim.mind && (victim.mind.assigned_role in list("Executive Officer", "Head of Personnel")))
				addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
				addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), 26 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			else
				addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
				addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cyborg
	display_name = "Cyborg Storage"
	msg = "has been activated from storage"
	restrict_job = list("Cyborg")

/datum/spawnpoint/cyborg/New()
	..()
	turfs = GLOB.latejoin_cyborg

/datum/spawnpoint/default
	display_name = DEFAULT_SPAWNPOINT_ID
	msg = "has arrived on the station"
	always_visible = TRUE