/datum/controller
	var/name
	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick
	var/obj/clickable_stat/__stat
	var/__stat_next = 0
	var/L_stat = FALSE

/datum/controller/proc/Initialize()

//cleanup actions
/datum/controller/proc/Shutdown()

//when we enter dmm_suite.load_map
/datum/controller/proc/StartLoadingMap()

//when we exit dmm_suite.load_map
/datum/controller/proc/StopLoadingMap()

/datum/controller/proc/Recover()

/datum/controller/proc/stat_entry()

/datum/controller/proc/UpdateStat(text)
    if (L_stat && text)
        if (ispath(/obj/clickable_stat)) // Проверяем существование типа
            var/obj/clickable_stat/__stat = new(null, src)
            __stat.name = text // Просто присваиваем текст без проверки listext
            stat(name, __stat)
        else
            stat(name, text) // Альтернативный вывод

/datum/controller/proc/PreventUpdateStat(time)
	if (!isnum(time))
		time = uptime()
	if (time < __stat_next)
		return TRUE
	__stat_next = time + 1 SECONDS
	return FALSE

/obj/clickable_stat