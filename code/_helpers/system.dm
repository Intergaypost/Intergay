/// Real time in deciseconds the server process has been active
/proc/uptime()
	var/static/days = 0
	var/static/start_time = world.timeofday
	var/static/last_time = start_time
	var/result

	var/time = world.timeofday
	if(time == last_time)
		return result
	if(time < last_time)
		++days
	last_time = time
	result = (time - start_time) + (days * 864000) // Вроде есть дефайн на день, но хуево работает.
	return result
