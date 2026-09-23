PROCESSING_SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = SS_PRIORITY_MOB
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/mob_list
	var/list/queue = list()

/datum/controller/subsystem/processing/mobs/PreInit()
	mob_list = processing // Simply setups a more recognizable var name than "processing"

/datum/controller/subsystem/processing/mobs/fire(resumed = 0)
	for(var/last_object in mob_list)
		var/mob/M = last_object
		if(istype(M) && !QDELETED(M))
			M.Life()
		else
			mob_list -= M
	sleep(wait)

/mob/dview/Initialize()
	. = ..()
	STOP_PROCESSING(SSmobs, src)