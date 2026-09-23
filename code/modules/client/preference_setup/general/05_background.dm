/datum/preferences
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/nanotrasen_relation = "Neutral"
	var/memory = ""

	//Some faction information.
	var/home_system = "Малые сектора"           //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "Atheism"               //Religious association.
	var/family = TRUE
	var/backstory = "Сотрудник"

/datum/category_item/player_setup_item/general/background
	name = "Background"
	sort_order = 5

/datum/category_item/player_setup_item/general/background/New(client/C)
	backstory_initialize()
	. = ..()

/datum/category_item/player_setup_item/general/background/load_character(var/savefile/S)
	from_file(S["med_record"],pref.med_record)
	from_file(S["sec_record"],pref.sec_record)
	from_file(S["gen_record"],pref.gen_record)
	from_file(S["home_system"],pref.home_system)
	from_file(S["citizenship"],pref.citizenship)
	from_file(S["religion"],pref.religion)
	from_file(S["family"],pref.family)
	from_file(S["nanotrasen_relation"],pref.nanotrasen_relation)
	from_file(S["memory"],pref.memory)
	from_file(S["backstory"],pref.backstory)

/datum/category_item/player_setup_item/general/background/save_character(var/savefile/S)
	to_file(S["med_record"],pref.med_record)
	to_file(S["sec_record"],pref.sec_record)
	to_file(S["gen_record"],pref.gen_record)
	to_file(S["home_system"],pref.home_system)
	to_file(S["citizenship"],pref.citizenship)
	to_file(S["religion"],pref.religion)
	to_file(S["family"],pref.family)
	to_file(S["nanotrasen_relation"],pref.nanotrasen_relation)
	to_file(S["memory"],pref.memory)
	to_file(S["backstory"],pref.backstory)

/datum/category_item/player_setup_item/general/background/sanitize_character()
	if(!pref.home_system)		 pref.home_system = get_backstory("Малые сектора")
	if(!pref.citizenship) 		pref.citizenship = "None"
	if(!pref.faction)    		pref.faction =     "None"
	if(!pref.religion)    		pref.religion =    "Atheism"
	if(!pref.backstory) pref.backstory = get_backstory("Житель станции")

	pref.nanotrasen_relation = sanitize_inlist(pref.nanotrasen_relation, COMPANY_ALIGNMENTS, initial(pref.nanotrasen_relation))

/datum/category_item/player_setup_item/general/background/content(var/mob/user)
	. += "<b>Background Information</b><br>"
	. += "Backstory: <a href='byond://?src=\ref[src];select_backstory=1'>[pref.backstory]</a><br/>"
	. += "Home System: <a href='byond://?src=\ref[src];home_system=1'>[pref.home_system]</a><br/>"
	. += "[GLOB.using_map.company_name] Relation: <a href='byond://?src=\ref[src];nt_relation=1'>[pref.nanotrasen_relation]</a><br/>"
	. += "Religion: <a href='byond://?src=\ref[src];religion=1'>[pref.religion]</a><br/>"

	. += "<br/><b>Records</b>:<br/>"
	if(jobban_isbanned(user, "Records"))
		. += "<span class='danger'>You are banned from using character records.</span><br>"
	else
		. += "Medical Records:<br>"
		. += "<a href='byond://?src=\ref[src];set_medical_records=1'>[TextPreview(pref.med_record,40)]</a><br><br>"
		. += "Employment Records:<br>"
		. += "<a href='byond://?src=\ref[src];set_general_records=1'>[TextPreview(pref.gen_record,40)]</a><br><br>"
		. += "Security Records:<br>"
		. += "<a href='byond://?src=\ref[src];set_security_records=1'>[TextPreview(pref.sec_record,40)]</a><br>"
		. += "Memory:<br>"
		. += "<a href='byond://?src=\ref[src];set_memory=1'>[TextPreview(pref.memory,40)]</a><br>"

/datum/category_item/player_setup_item/general/background/get_data(var/mob/user)
	var/datum/backstory/BS = get_backstory(pref.backstory)
	return list(
		"ref" = "\ref[src]",
		"backstory_name" = BS ? BS.name : (pref.backstory ? pref.backstory : "None"),
		"backstory_category" = BS ? BS.category : "General",
		"backstory_desc" = BS ? BS.desc : "",
		"backstory_fluff" = BS ? BS.fluff : "",
		"company_name" = GLOB.using_map.company_name,
		"nt_relation" = pref.nanotrasen_relation,
		"home_system" = pref.home_system,
		"citizenship" = pref.citizenship,
		"religion" = pref.religion,
		"has_records_ban" = jobban_isbanned(user, "Records") ? 1 : 0,
		"med_record" = pref.med_record ? pref.med_record : "",
		"med_record_preview" = pref.med_record ? TextPreview(pref.med_record, 40) : "None",
		"gen_record" = pref.gen_record ? pref.gen_record : "",
		"gen_record_preview" = pref.gen_record ? TextPreview(pref.gen_record, 40) : "None",
		"sec_record" = pref.sec_record ? pref.sec_record : "",
		"sec_record_preview" = pref.sec_record ? TextPreview(pref.sec_record, 40) : "None",
		"memory" = pref.memory ? pref.memory : "",
		"memory_preview" = pref.memory ? TextPreview(pref.memory, 40) : "None"
	)

/datum/category_item/player_setup_item/general/background/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["select_backstory"] || href_list["backstory"])
		var/list/choices = list()
		for(var/datum/backstory/story/bs in GLOB.all_backstories)
			if(bs.name != "None")
				choices += bs
		var/datum/backstory/choice = input(user, "Выбери предысторию персонажа:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.backstory) as null|anything in choices
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		pref.backstory = choice
		to_chat(user, "<hr><b><span class='info'>[choice]: [choice.fluff] </b></span><br><span class='notice'>STATS: [choice.desc]</span><hr>")
		return TOPIC_REFRESH

	else if(href_list["nt_relation"])
		var/new_relation = input(user, "Choose your relation to [GLOB.using_map.company_name]. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.nanotrasen_relation)  as null|anything in COMPANY_ALIGNMENTS
		if(new_relation && CanUseTopic(user))
			pref.nanotrasen_relation = new_relation
			return TOPIC_REFRESH

	else if(href_list["home_system"])
		var/list/choices = list()
		for(var/datum/backstory/homesystem/bs in GLOB.all_backstories)
			if(bs.name != "None")
				choices += bs
		var/datum/backstory/choice = input(user, "Выбери родную систему:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.home_system) as null|anything in choices
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		pref.home_system = choice
		to_chat(user, "<hr><b><span class='info'>[choice]: [choice.fluff]</b></span><br><span class='notice'>STATS: [choice.desc]</span><hr>")
		return TOPIC_REFRESH

	/*
	else if(href_list["citizenship"])
		var/choice = input(user, "Please choose your current citizenship.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.citizenship) as null|anything in GLOB.using_map.citizenship_choices + list("None","Other")
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		if(choice == "Other")
			var/raw_choice = sanitize(input(user, "Please enter your current citizenship.", CHARACTER_PREFERENCE_INPUT_TITLE) as text|null, MAX_NAME_LEN)
			if(raw_choice && CanUseTopic(user))
				pref.citizenship = raw_choice
		else
			pref.citizenship = choice
		return TOPIC_REFRESH
	*/

	else if(href_list["religion"])
		var/choice = input(user, "Please choose a religion.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.religion) as null|anything in GLOB.using_map.religion_choices + list("None","Other")
		if(!choice || !CanUseTopic(user))
			return TOPIC_NOACTION
		if(choice == "Other")
			var/raw_choice = sanitize(input(user, "Please enter a religon.", CHARACTER_PREFERENCE_INPUT_TITLE)  as text|null, MAX_NAME_LEN)
			if(raw_choice)
				pref.religion = sanitize(raw_choice)
		else
			pref.religion = choice
		return TOPIC_REFRESH

	else if(href_list["set_medical_records"])
		var/new_medical = sanitize(input(user,"Enter medical information here.",CHARACTER_PREFERENCE_INPUT_TITLE, html_decode(pref.med_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(new_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.med_record = new_medical
		return TOPIC_REFRESH

	else if(href_list["set_general_records"])
		var/new_general = sanitize(input(user,"Enter employment information here.",CHARACTER_PREFERENCE_INPUT_TITLE, html_decode(pref.gen_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(new_general) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.gen_record = new_general
		return TOPIC_REFRESH

	else if(href_list["set_security_records"])
		var/sec_medical = sanitize(input(user,"Enter security information here.",CHARACTER_PREFERENCE_INPUT_TITLE, html_decode(pref.sec_record)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(sec_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.sec_record = sec_medical
		return TOPIC_REFRESH

	else if(href_list["set_memory"])
		var/memes = sanitize(input(user,"Enter memorized information here.",CHARACTER_PREFERENCE_INPUT_TITLE, html_decode(pref.memory)) as message|null, MAX_PAPER_MESSAGE_LEN, extra = 0)
		if(!isnull(memes) && CanUseTopic(user))
			pref.memory = memes
		return TOPIC_REFRESH

	return ..()
