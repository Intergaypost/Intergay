/mob/new_player
	var/selected_department = "All"

/mob/new_player/proc/LateChoices()
	if(!client)
		return
	ui_interact(src)

/mob/new_player/ui_interact(mob/user, ui_key = "latejoin", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/nanoui/master_ui = null, var/datum/topic_state/state = GLOB.interactive_state)
	if(!user || !user.client || !user.client.prefs)
		return

	var/datum/preferences/prefs = user.client.prefs

	if(!prefs.preview_icon)
		prefs.update_preview_icon()
	if(prefs.preview_icon && user.client)
		user << browse_rsc(prefs.preview_icon, "previewicon.png")

	var/list/data = list()
	data["character_name"] = prefs.real_name
	data["species"] = prefs.species
	data["gender"] = prefs.gender
	data["gender_text"] = (prefs.gender == MALE ? "Male" : (prefs.gender == FEMALE ? "Female" : prefs.gender))
	data["age"] = prefs.age
	data["slot"] = prefs.default_slot
	data["max_slots"] = config.character_slots || 10
	data["spawnpoint"] = prefs.spawnpoint
	data["char_branch"] = (GLOB.using_map.flags & MAP_HAS_BRANCH) ? prefs.char_branch : null
	data["char_rank"] = (GLOB.using_map.flags & MAP_HAS_RANK) ? prefs.char_rank : null
	data["preview_version"] = world.time
	data["preview_job_gear"] = (prefs.equip_preview_mob & EQUIP_PREVIEW_JOB) ? 1 : 0
	data["station_name"] = station_name()
	data["round_duration"] = roundduration2text()
	data["enter_allowed"] = config.enter_allowed ? 1 : 0
	data["explosion_in_progress"] = (SSticker.mode && SSticker.mode.explosion_in_progress) ? 1 : 0
	data["name_taken"] = (prefs.real_name in GLOB.player_name_list) ? 1 : 0
	data["show_invalid_jobs"] = show_invalid_jobs ? 1 : 0
	data["selected_department"] = selected_department ? selected_department : "All"

	// Evacuation status
	var/evac_status = "Station Operational"
	var/evac_alert_level = "normal"
	if(SSevac.evacuation_controller.has_evacuated())
		evac_status = "Station Evacuated"
		evac_alert_level = "danger"
	else if(SSevac.evacuation_controller.is_evacuating())
		if(SSevac.evacuation_controller.emergency_evacuation)
			evac_status = "Emergency Evacuation In Progress"
			evac_alert_level = "danger"
		else
			evac_status = "Crew Transfer Procedures In Progress"
			evac_alert_level = "warning"
	data["evac_status"] = evac_status
	data["evac_alert_level"] = evac_alert_level

	data["has_gender_lock"] = (prefs.gender != MALE) ? 1 : 0

	// Character slot list
	var/list/slots_data = list()
	var/max_slots = config.character_slots || 10
	for(var/i = 1 to max_slots)
		slots_data += list(list(
			"num" = i,
			"is_current" = (i == prefs.default_slot)
		))
	data["slots"] = slots_data

	// Count active crew by role
	var/list/active_by_job = list()
	var/active_crew_total = 0
	for(var/mob/M in GLOB.player_list)
		if(M.mind && M.client && M.mind.assigned_role && M.client.inactivity <= 10 * 60 * 10)
			active_by_job[M.mind.assigned_role]++
			active_crew_total++
	data["active_crew_total"] = active_crew_total

	// Departments list
	var/list/departments_order = list("Command", "Security", "Engineering", "Medical", "Science", "Supply", "Service", "Exploration", "Inquisition", "Common")
	var/list/dept_jobs = list()
	for(var/dept in departments_order)
		dept_jobs[dept] = list()

	var/total_open_positions = 0

	if(job_master)
		for(var/datum/job/job in job_master.occupations)
			var/dept_name = get_department_names(job)
			if(!dept_jobs[dept_name])
				dept_jobs[dept_name] = list()

			var/is_available = 1
			var/unavailable_reason = null

			if(job.sex_lock && prefs.gender != job.sex_lock)
				is_available = 0
				unavailable_reason = "GENDER LOCKED"
			else if(job.total_positions == 0 && job.spawn_positions == 0)
				is_available = 0
				unavailable_reason = "DISABLED"
			else if(!job.is_position_available())
				is_available = 0
				unavailable_reason = "POSITIONS FULL"
			else if(jobban_isbanned(src, job.title))
				is_available = 0
				unavailable_reason = "BANNED"
			else if(user.client && !job.player_old_enough(user.client))
				is_available = 0
				unavailable_reason = "IN [job.available_in_days(user.client)] DAYS"
			else if(job.minimum_character_age && prefs.age < job.minimum_character_age)
				is_available = 0
				unavailable_reason = "MIN AGE [job.minimum_character_age]"
			else if(job.is_restricted(prefs))
				is_available = 0
				var/datum/species/S = all_species[prefs.species]
				if(!job.is_species_allowed(S))
					unavailable_reason = "SPECIES RESTRICTED"
				else if(!job.is_branch_allowed(prefs.char_branch))
					unavailable_reason = "BRANCH RESTRICTED"
				else if(!job.is_rank_allowed(prefs.char_branch, prefs.char_rank))
					unavailable_reason = "RANK RESTRICTED"
				else
					unavailable_reason = "RESTRICTED"

			if(is_available)
				total_open_positions++

			var/alt_title = prefs.GetPlayerAltTitle(job)
			var/is_head = ((job.title in GLOB.command_positions) || (job.title == "AI") || (job.head_position)) ? 1 : 0
			var/active_count = active_by_job[job.title] || 0

			dept_jobs[dept_name] += list(list(
				"title" = job.title,
				"alt_title" = alt_title,
				"has_alt_titles" = (job.alt_titles && job.alt_titles.len > 0) ? 1 : 0,
				"selection_color" = job.selection_color,
				"is_head" = is_head,
				"current_positions" = job.current_positions,
				"total_positions" = job.total_positions,
				"active_players" = active_count,
				"is_available" = is_available,
				"unavailable_reason" = unavailable_reason
			))

	var/list/departments_data = list()
	for(var/dept_name in dept_jobs)
		var/list/jobs_in_dept = dept_jobs[dept_name]
		if(!jobs_in_dept || !jobs_in_dept.len)
			continue

		var/available_in_dept = 0
		var/total_in_dept = jobs_in_dept.len
		var/active_in_dept = 0

		for(var/list/J in jobs_in_dept)
			if(J["is_available"])
				available_in_dept++
			active_in_dept += J["active_players"]

		departments_data += list(list(
			"name" = dept_name,
			"available_count" = available_in_dept,
			"total_count" = total_in_dept,
			"active_count" = active_in_dept,
			"is_selected" = (selected_department == dept_name),
			"jobs" = jobs_in_dept
		))

	data["departments"] = departments_data
	data["total_open_positions"] = total_open_positions

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "latejoin.tmpl", "Latejoin - [station_name()]", 980, 720, state = state)
		ui.add_stylesheet("character_setup.css")
		ui.add_stylesheet("latejoin.css")
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
