SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	flags = SS_NO_FIRE
	priority = SS_PRIORITY_RUNECHAT
	var/list/message_queue = list()

/datum/controller/subsystem/runechat/Recover()
	message_queue = list()
