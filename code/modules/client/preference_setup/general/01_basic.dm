datum/preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Cryogenic Storage" 			//where this character will spawn (0-2).
	var/metadata = ""

/datum/category_item/player_setup_item/general/basic
	name = "Basic"
	sort_order = 1

/datum/category_item/player_setup_item/general/basic/load_character(var/savefile/S)
	S["real_name"]				>> pref.real_name
	S["name_is_always_random"]	>> pref.be_random_name
	S["gender"]					>> pref.gender
	S["age"]					>> pref.age
	S["spawnpoint"]				>> pref.spawnpoint
	//S["OOC_Notes"]				>> pref.metadata
	S["religion"]				>> pref.religion
	//S["family"]					>> pref.family

/datum/category_item/player_setup_item/general/basic/save_character(var/savefile/S)
	S["real_name"]				<< pref.real_name
	S["name_is_always_random"]	<< pref.be_random_name
	S["gender"]					<< pref.gender
	S["age"]					<< pref.age
	S["spawnpoint"]				<< pref.spawnpoint
	//S["OOC_Notes"]				<< pref.metadata
	S["religion"]				<< pref.religion
	//S["family"]					<< pref.family

/datum/category_item/player_setup_item/general/basic/sanitize_character()
	var/datum/species/S = all_species[pref.species ? pref.species : SPECIES_HUMAN]
	if(!S) S = all_species[SPECIES_HUMAN]
	pref.age                = sanitize_integer(pref.age, S.min_age, S.max_age, initial(pref.age))
	pref.gender             = sanitize_inlist(pref.gender, S.genders, pick(S.genders))
	pref.real_name          = sanitize_name(pref.real_name, pref.species)
	if(!pref.real_name || pref.real_name == "")
		pref.real_name      = random_name(pref.gender, pref.species)
	pref.spawnpoint         = sanitize_inlist(pref.spawnpoint, spawntypes(), initial(pref.spawnpoint))
	pref.be_random_name     = sanitize_integer(pref.be_random_name, 0, 1, initial(pref.be_random_name))
	if(!pref.religion)    pref.religion =  LEGAL_RELIGION

/datum/category_item/player_setup_item/general/basic/content()
	. = list()
	. += "<b>Gender:</b> <a href='byond://?src=\ref[src];gender=1'><b>[pref.gender == MALE ? "Male" : "Female"]</b></a><br>"
	. += "<b>Age:</b> <a href='byond://?src=\ref[src];age=1'>[pref.age]</a><br>"
	//. += "<b>Spawn Point</b>: <a href='byond://?src=\ref[src];spawnpoint=1'>[pref.spawnpoint]</a><br>"
	. += "<b>RELIGION</b> "
	. += "<a href='byond://?src=\ref[src];religion=1'>[pref.religion]</a><br/>"
	//. += "<b>Join Families</b> "
	//. += "<a href='byond://?src=\ref[src];family=1'>[pref.family ? "Yes" : "No"]</a><br/>"
	//if(config.allow_Metadata)
		//. += "<b>OOC Notes:</b> <a href='byond://?src=\ref[src];metadata=1'> Edit </a><br>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/general/basic/get_data(var/mob/user)
	var/datum/species/S = all_species[pref.species ? pref.species : SPECIES_HUMAN]
	if(!S) S = all_species[SPECIES_HUMAN]
	return list(
		"ref" = "\ref[src]",
		"real_name" = pref.real_name,
		"be_random_name" = pref.be_random_name ? 1 : 0,
		"gender" = pref.gender,
		"gender_text" = (pref.gender == MALE ? "Male" : (pref.gender == FEMALE ? "Female" : pref.gender)),
		"age" = pref.age,
		"min_age" = S.min_age,
		"max_age" = S.max_age,
		"religion" = pref.religion,
		"spawnpoint" = pref.spawnpoint
	)

/datum/category_item/player_setup_item/general/basic/OnTopic(var/href,var/list/href_list, var/mob/user)
	var/datum/species/S = all_species[pref.species]
	if(href_list["rename"])
		var/raw_name = input(user, "Choose your character's name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				if(GLOB.in_character_filter.len) //If you name yourself brazil, you're getting a random name.
					if(findtext(new_name, config.ic_filter_regex))
						new_name = random_name(pref.gender, pref.species)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				to_chat(user, "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>")
				return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	else if(href_list["gender"])
		var/new_gender = input(user, "Choose your character's gender:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.gender) as null|anything in S.genders
		S = all_species[pref.species]
		if(new_gender && CanUseTopic(user) && (new_gender in S.genders))
			pref.gender = new_gender
			if(!(pref.f_style in S.get_facial_hair_styles(pref.gender)))
				ResetFacialHair()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["age"])
		var/new_age = input(user, "Choose your character's age:\n([S.min_age]-[S.max_age])", CHARACTER_PREFERENCE_INPUT_TITLE, pref.age) as num|null
		if(new_age && CanUseTopic(user))
			pref.age = sanitize_integer(new_age, S.min_age, S.max_age, pref.age)
			return TOPIC_REFRESH

	else if(href_list["spawnpoint"])
		var/list/spawnkeys = list()
		for(var/spawntype in spawntypes())
			spawnkeys += spawntype
		var/choice = input(user, "Where would you like to spawn when late-joining?") as null|anything in spawnkeys
		if(!choice || !spawntypes()[choice] || !CanUseTopic(user))	return TOPIC_NOACTION
		pref.spawnpoint = choice
		return TOPIC_REFRESH
	else if(href_list["religion"])

		if(pref.religion == LEGAL_RELIGION)
			pref.religion = ILLEGAL_RELIGION
		else
			pref.religion = LEGAL_RELIGION
		return TOPIC_REFRESH

	else if(href_list["family"])
		pref.family = !pref.family
		return TOPIC_REFRESH

	else if(href_list["metadata"])
		var/new_metadata = sanitize(input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , pref.metadata) as message|null)
		if(new_metadata && CanUseTopic(user))
			pref.metadata = new_metadata
			return TOPIC_REFRESH

	return ..()
