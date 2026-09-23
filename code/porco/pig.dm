/client/
	var/scrollbarready = 0

/client/proc/loadDataPig()
	var/datum/asset/stuff = get_asset_datum(/datum/asset/pig)
	stuff.register()
	stuff.send(src)

/client/verb/ready()
	set hidden = 1
	set name = "doneRsc"

	pigReady = 1

/client/verb/unready()
	set hidden = 1
	set name = "notdoneRsc"

	pigReady = 0

/mob/new_player/proc/updateTimeToStart()
	if(!client)
		return
	if(!client.pigReady)
		return
	client << output(list2params(list("#timestart", "[floor(SSticker?.pregame_timeleft)]")), "outputwindow.browser:change")

/mob/new_player/Login()
	..()
	spawn while(client)
		sleep(10)
		updateTimeToStart()
		updatePig()

/mob/new_player/Life()
	..()
	updateTimeToStart()
	updatePig()

/mob/living/carbon/human/proc/updateSpider()
	if(!client)
		return

	var/list/text = list()
	var/fulltext = ""

/*
	if(src?.mind?.succubus)
		text += "<a href='byond://#' id='teleportSlaves'>Teleport Slaves<br></a><a href='byond://#' id='punishSlave'>Punish Slave<br></a> <a href='byond://#' id='killSlave'>Kill Slave<br></a>"


	if(src.verbs.Find(/mob/living/carbon/human/proc/plantEgg))
		text += "<a href='byond://#' id='plantEgg'>Lay Egg<br></a>"
	if(src.verbs.Find(/mob/living/carbon/human/proc/plantWeeds))
		text += "<a href='byond://#' id='plantWeeds'>Plant Weeds<br></a>"

	switch(job)
		if("Bishop")
			text += "<a href='byond://#'' id='Excommunicate'>Excommunicate<br></a><a href='byond://#'' id='BannishtheUndead'>Banish Undead</a><a href='byond://#'' id='RobofSins'><br>Rob of Sins<br></a><a href='byond://#' id='Epitemia''>Epitemia<br></a><a href='byond://#'' id='RewardtheInquisitor'>Reward the Inquisitor</a><a href='byond://#'' id='Coronation'><br>Coronation</a><a href='byond://#'' id='Eucharisty'><br>Eucharisty<br></a><a href='byond://#'' id='BannishSpirits'>Banish Spirits<br></a><a href='byond://#'' id='CallforChurchMeeting'>Call for Chuch Meeting<br></a><a href='byond://#' id='Marriage''>Marriage!<br></a><a href='byond://#' id='ClearName''>Clear Name<br></a>"
		if("Priest")
			text += "<a href='byond://#'' id='Excommunicate'>Excommunicate<br></a><a href='byond://#'' id='BannishtheUndead'>Banish Undead</a><a href='byond://#'' id='RobofSins'><br>Rob of Sins<br></a><a href='byond://#' id='Epitemia''>Epitemia<br></a><a href='byond://#'' id='RewardtheInquisitor'>Reward the Inquisitor</a><a href='byond://#'' id='Coronation'><br>Coronation</a><a href='byond://#'' id='Eucharisty'><br>Eucharisty<br></a><a href='byond://#'' id='BannishSpirits'>Banish Spirits<br></a><a href='byond://#'' id='CallforChurchMeeting'>Call for Chuch Meeting<br></a><a href='byond://#' id='Marriage''>Marriage!<br></a><a href='byond://#' id='ClearName''>Clear Name<br></a>"
		if("Monk")
			text += "<a href='byond://#'' id='BannishtheUndead'>Banish Undead</a><a href='byond://#'' id='RobofSins'><br>Rob of Sins<br></a><a href='byond://#'' id='Eucharisty'><br>Eucharisty<br></a><a href='byond://#'' id='BannishSpirits'>Banish Spirits<br></a><a href='byond://#' id='Marriage!''>Marriage<br></a>"
		if("Expedition Leader")
			text += "<a href='byond://#' id='SetMigSpawn'>Set Migrant Arrival<br></a><a href='byond://#' id='announceEx'>Announce (14 TILES)<br></a>"
		if("Bum")
			text += "<a href='byond://#' id='tellTheTruth'>Tell the Truth<br></a>"
		if("Urchin")
			text += "<a href='byond://#' id='tellTheTruth'>Tell the Truth<br></a>"

		if("Migrant")
			if(!migclass)
				if(ckey in outlaw)
					text += "<a href='byond://#' id='ChoosemigrantClass'>Choose Migrant Class!<br></a><a href='byond://#' id='ToggleOutlaw'>Toggle Outlaw!<br></a>"
				else
					text += "<a href='byond://#' id='ChoosemigrantClass'>Choose Migrant Class!<br></a>"

		if("Count")
			text += "<a href='byond://#' id='Reinforcement'>Change Reinforcement Type<br></a><a href='byond://#' id='Command'>Command<br></a><a href='byond://#' id='SpecialReinforcement'>Call for Special Reinforcement!<br></a><a href='byond://#' id='Recruit'>Recruit<br></a><a href='byond://#' id='CaptureThrone'>Capture Throne<br></a>"
		if("Count Hand")
			text += "<a href='byond://#' id='Command'>Command<br></a><a href='byond://#' id='SpecialReinforcement'>Call for Special Reinforcement!<br></a><a href='byond://#' id='Recruit'>Recruit<br></a>"
		if("Count Heir")
			text += "<a href='byond://#' id='SpecialReinforcement'>Call for Special Reinforcement!<br></a>"

	if(src.consyte)
		text += "<a href='byond://#' id='Choir'>Choir<br></a><a href='byond://#' id='respark'>Respark<br></a>"

	if(src.job == "Jester")
		text += "<a href='byond://#' id='Choir'>Choir<br></a><a href='byond://#' id='nickname'>Give a nickname!<br></a>"
		text += "<a href='byond://#' id='Choir'>Choir<br></a><a href='byond://#' id='juggle'>Juggle!<br></a>"
		text += "<a href='byond://#' id='Choir'>Choir<br></a><a href='byond://#' id='rememberjoke'>Remember Joke!<br></a>"
		text += "<a href='byond://#' id='Choir'>Choir<br></a><a href='byond://#' id='joke'>Joke!<br></a>"
*/
	for(var/T in text)
		fulltext += "[T]"


/mob/living/carbon/human/proc/updateSmalltext()
	if(!client)
		return

	var/list/text = list()
	var/fulltext = ""

/*
	if(job == "Pusher")
		if(mind)
			text += "TIME TO PAY: <span id='timepusher'>[secondsToMintues(mind.time_to_pay)]</span>"
	if(job == "Inquisitor")
		if(mind && Inquisitor_Type == "Month's Inquisitor")
			text += "Avowals of Guilt sent: (<span id='timepusher'>[secondsToMintues(mind.avowals_of_guilt_sent)] / 6)</span>"
		text += "Inquisitorial Points: <span id='timepusher'>[Inquisitor_Points]</span>"
*/

/*
	if(religion)
		if(religion == HASARD)
			text += "THOU ARE HASARD'S TOY"
*/

/*
	if(src?.mind?.succubus)
		text += "Slaves : [src.mind.succubus.succubusSlaves.len]"
*/

/*
	if(ticker.mode.config_tag == "siege" && siegesoldier)
		var/datum/game_mode/siege/S = ticker.mode
		text += "Losses: [S.losses]/[S.max_losses]"

	else if(ticker.mode.config_tag == "miniwar" && mini_war)
		var/datum/game_mode/miniwar/M = ticker.mode
		switch(mini_war)
			if("Northner")
				text += "Losses: [M.north_count]/[M.max_count]"
			if("Southner")
				text += "Losses: [M.south_count]/[M.max_count]"
*/

	for(var/T in text)
		fulltext += "[T]<br>"

	return fulltext

/proc/generateVerbHtml(var/verbname = "", var/displayname = "", var/number = 1)
	if(number % 2)
		return {"<a href='byond://#' class='verb dim' onclick='window.location = "byond://winset?command=[verbname]"'>[displayname]</a>"}
	return {"<a href='byond://#' class='verb' onclick='window.location = "byond://winset?command=[verbname]"'>[displayname]</a>"}

/proc/generateVerbList(var/list/verbs = list(), var/count = 1)
	var/html = ""
	var/counter = count
	for(var/list/L in verbs)
		counter++
		html += generateVerbHtml(L[1], L[2], counter) + "$"

	return html

/client/proc/newtext(var/newcontent = "")
	src << output(list2params(list("[newcontent]")), "outputwindow.browser:InputMsg")

/client/proc/changebuttoncontent(var/idcontent = "", var/newcontent = "")
	src << output(list2params(list("[newcontent]", "[idcontent]")), "outputwindow.browser:changel")

/client/proc/addbutton(var/newcontent = "", var/selector = "")
	src << output(list2params(list("[newcontent]", "[selector]")), "outputwindow.browser:addel")

/mob/proc/updatePig()
	set waitfor = 0
	if(!client)
		return
	if(!client.pigReady)
		return

	var/buttonHTML = ""
	defaultButton()

	buttonHTML += {"<a href="#"><div style="background-image: url(\'Heart.png\'); margin-top: -129px; margin-right: 8px;" id="Verb" class="button" /></div></a>"}

	if(src.stat == DEAD && GAME_STATE != RUNLEVEL_LOBBY || isobserver(src) || istype(src, /mob/living/carbon/brain))
		buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Dead.png\'); margin-top: -88px; margin-left:46px; \" id=\"DeadGhost\" class=\"button\" /></div></a>"

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Emotes.png\'); margin-top: -44px; margin-left: 46px; \" id=\"Emotes\" class=\"button\" /></div></a>"
		buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Craft.png\'); margin-top: 2px; margin-left:46px; \" id=\"Craft\" class=\"button\" /></div></a>"

/*
		if(H.isVampire)
			buttonTimes++;
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Fangs.png\'); margin-top: -50px; margin-left:[pixelDistancing * buttonTimes]px; \" id=\"Vampire\" class=\"button\" /></div></a>"
*/
/*
		if(H.job == "Francisco's Advisor")
			buttonTimes++;
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Plot.png\'); margin-top: -50px; margin-left:[pixelDistancing * buttonTimes]px; \" id=\"Advisor\" class=\"button\" /></div></a>"
		if(H.job == "Francisco's Bodyguard")
			buttonTimes++;
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Plot.png\'); margin-top: -50px; margin-left:[pixelDistancing * buttonTimes]px; \" id=\"Bodyguard\" class=\"button\" /></div></a>"
*/
		if(H?.mind)
			if(H?.mind?.changeling)
				buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Villain.png\'); margin-top: -132px; margin-left:46px; \" id=\"They\" class=\"button\" /></div></a>"
			if(H.mind.special_role == "Head Revolutionary")
				buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Epsilon.png\'); margin-top: -132px; margin-left:46px; \" id=\"Integralist\" class=\"button\" /></div></a>"
		if(H?.religion != LEGAL_RELIGION)
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Thanati.png\'); margin-top: 1px; margin-left:46px; \" id=\"Thanati\" class=\"button\" /></div></a>"
		if(istype(H.head, /obj/item/clothing/head/caphat))
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Crown.png\'); margin-top: -50px; margin-left:46px; \" id=\"Crown\" class=\"button\" /></div></a>"
		if(H.stat == DEAD)
			buttonHTML += "<a href=\"#\"><div style=\"background-image: url(\'Dead.png\'); margin-top: -88px; margin-left:46px; \" id=\"Dead\" class=\"button\" /></div></a>"

	client.addbutton(buttonHTML, "#dynamicpanel")
	updateButtons()

/mob/proc/noteUpdate()
	var/newHTML = ""

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		newHTML += "<span style='white-space: nowrap' class='segment1 ST'>ST: <span id='st'>[H.stats[STAT_ST]]</span>$HT: <span id='ht'>[H.stats[STAT_HT]]</span>$IN: <span id='int'>[H.stats[STAT_IQ]]</span>$DX: <span id='dx'>[H.stats[STAT_DX]]</span></span>"
		newHTML += "<span class='smallstat'>[H.updateSmalltext()]</span>"

	return newHTML

/mob/proc/updateButtons()
	set waitfor = 0
	if(!client)
		return
	if(!client.pigReady)
		return

	client.changebuttoncontent("#note", noteUpdate())
	client.changebuttoncontent("#Verb", verbUpdate())
	client.changebuttoncontent("#Emotes", {"<span class='segment1'>[generateVerbList(list(list("slap", "Slap"), list("Nod", "Nod"), list("Hug", "Hug"), list("Bow", "Bow"), list("Scream", "Scream"), list("Whimper", "Whimper"), list("Laugh", "Laugh"), list("Sigh", "Sigh")))]</span>"} + {"<span class='segment2'>[generateVerbList(list(list("Cough", "Cough"), list("Yawn", "Yawn"), list("Wink", "Wink"), list("Grumble", "Grumble"), list("Charge", "Charge"), list("Cry", "Cry"), list("Hem", "Hem"), list("ClearThroat", "Clear Throat"), list("Smile", "Smile")), 2)]</span>"})
	client.changebuttoncontent("#Craft", {"<span class='segment1'>[generateVerbList(list(list("CraftMenu", "Craft Menu")))]</span>"})

	client.changebuttoncontent("#DeadGhost", {"<span class='segment1'>[generateVerbList(list(list("JoinHellDelverSquad", "Fight in Hell"), list("ToggleGhostVision", "Toggle Ghost Vision"), list("ToggleAnonymousChat", "Become Anonymous"), list("ToggleDarkness", "Add Light"), list("BecomeMouse", "Transform into a Mouse"), list("FollowGhost", "Follow"), list("TeleportGhost", "Teleport"), list("ToggleAntagHUD", "Toggle Antag HUD"), list("ToggleMedicHUD", "Toggle Medic HUD"), list("MoveUp", "Move Upwards"), list("MoveDown", "Move Down"), list("ReenterCorpse", "Re-enter Corpse")))]</span>"})
	client.changebuttoncontent("#Dead", {"<span class='segment1'>[generateVerbList(list(list("Succumb", "Succumb")))]</span>"})

	client.changebuttoncontent("#Vampire", {"<span class='segment1'>[generateVerbList(list(list("ExposeFangs", "Expose Fangs"), list("BloodStrength", "Blood Strength (50cl)"), list("Fortitude", "Fortitude (50cl)"), list("Heal", "Heal (150cl)"), list("Celerety", "Celerety (250cl)"), list("DeadEyes", "Dead Eyes")))]</span>"})
	client.changebuttoncontent("#Advisor", {"<span class='segment1'>[generateVerbList(list(list("gradeHygiene", "Grade the Hygiene"), list("gradePeople", "Grade the People"), list("gradeFortress", "Grade the Fortress")))]</span>"})
	client.changebuttoncontent("#Bodyguard", {"<span class='segment1'>[generateVerbList(list(list("localizeAdvisor", "Localize Advisor")))]</span>"})
	client.changebuttoncontent("#They", {"<span class='segment1'>[generateVerbList(list(list("EvolutionMenu", "Evolve"), list("RangedSting", "Ranged Attack"), list("AbsorbDNA", "Absorb Victim"), list("Transform", "Transform"), list("LesserForm", "Lesser Form"), list("TransformLesser", "Lesser Transform"), list("ReviveLing", "Revive"), list("EpinephrineSacs", "Epinephrine Sacs"), list("ToggleDigitalCamoflague", "Hide from AI"), list("RapidRegeneration", "Rapid Regeneration"), list("HiveChannel", "Hive Channel"), list("HiveAbsorb", "Hive Absorb"), list("MimicVoice", "Mimic Voice"), list("HallucinationSting", "Hallucination Sting"), list("SilenceSting", "Silence Sting"), list("BlindSting", "Blind Sting"), list("ParalysisSting", "Paralysis Sting"), list("DeafSting", "Deaf Sting"), list("TransformationSting", "Transformation Sting"), list("DeathSting", "Death Sting"), list("ExtractDNASting", "Extract DNA Sting"), list("BuffStats", "Enhance ourselves"), list("RegenerativeStasis", "Regenerative Stasis")))]</span>"})
	client.changebuttoncontent("#Crown", {"<span class='segment1'>[generateVerbList(list(list("DecretodoBarao", "Baron Decree"), list("Abrirtrapdoors", "Open Traps"), list("ColocarTaxas", "Impose Fees"), list("Declararalerta", "Declare Emergency"), list("VendadeDrogas", "Drug Sell"), list("VendadeArmas", "Gun Sell"), list("Expandirpoderesdaigreja", "Expand Church Power"), list("SetHands", "Set Hand")))]</span>"})
	client.changebuttoncontent("#Integralist", {"<span class='segment1'>[generateVerbList(list(list("ConvertBourgeoise", "Convert to our Cause")))]</span>"})
	client.changebuttoncontent("#Thanati", {"<span class='segment1'>[generateVerbList(list(list("PraiseyourGod", "Call to the Lord"), list("CreateShrine", "Create a Shrine"), list("getBrothers", "Remember the Associates")))]</span>"})

/mob/proc/verbUpdate()
	var/newHTML = ""
	var/mob/new_player/player = usr
	if(istype(src, /mob/new_player))
		var/lobby = ""
		if(GAME_STATE <= RUNLEVEL_LOBBY)
			lobby += "<span style='color:#1cfc03'>Time to Start: [SSticker.pregame_timeleft/10]</span>$"
			for(var/client/C)
				var/gendercheck = "MALE"
				var/readycheck = "NOT READY"

				if(C.prefs.gender != MALE)
					gendercheck = "FEMALE"
				if(player.ready)
					readycheck = "READY"

				lobby += "<b>[C.ckey]</b> ([C.prefs.age] [gendercheck]) <b>[readycheck]</b>$"
			newHTML += {"<span style='color:#0e3b0e; font-weight:bold;'>[lobby]</span>"}
	if(ishuman(src))
		newHTML += {"<span class='segment1'>[generateVerbList(list(list("DisguiseVoice", "Disguise Voice"), list("Dance", "Dance"), list("Pee", "Pee"), list("LookUp", "Look Up"), list("MoveUp", "Move Upwards"), list("ShowGoals", "Show Goals")))]</span>"} + {"<span class='segment2'>[generateVerbList(list(list("Notes", "Memories"), list("AddNote", "Add Memories"), list("Pray", "Pray"), list("Poo", "Poo"), list("LookDown", "Look Down"), list("MoveDown", "Move Down")), 2)]</span>"}
	return newHTML

/mob/proc/spiderUpdate()
	var/newOption = ""
	var/list/verbs = list()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		verbs += list(list("RememberTheTerrain", "Remember the Terrain"))

/*
		if(is_dreamer(H))
			verbs += list(list("Wonders", "Wonders"))
		if(H.reflectneed >= 750)
			verbs += list(list("ReflectExperience", "Reflect your Experience!"))
		if(H?.mind?.succubus)
			verbs += list(list("teleportSlaves", "Teleport Slaves"), list("killSlave", "Kill Slave"))
		if(istype(H?.species, /datum/species/human/alien))
			verbs += list(list("plantWeeds", "Plant Weeds"), list("plantEgg", "Lay Egg"))
*/

/*
		if(H.job == "Bishop" || H.old_job == "Bishop")
			verbs += list(list("Excommunicate", "Excommunicate"), list("BannishtheUndead", "Banish Undead"), list("RobofSins", "Rob of Sins"), list("Epitemia", "Epitemia"), list("RewardtheInquisitor", "Reward the Inquisitor"), list("Coronation", "Coronation"), list("Eucharisty", "Eucharisty"), list("BannishSpirits", "Banish Spirits"), list("CallforChurchMeeting", "Call for Church Meeting"), list("Marriage", "Marriage!"), list("ClearName", "Clear Name"))
		if(H.job == "Priest" || H.old_job == "Priest")
			verbs += list(list("Excommunicate", "Excommunicate"), list("BannishtheUndead", "Banish Undead"), list("RobofSins", "Rob of Sins"), list("Epitemia", "Epitemia"), list("RewardtheInquisitor", "Reward the Inquisitor"), list("Coronation", "Coronation"), list("Eucharisty", "Eucharisty"), list("BannishSpirits", "Banish Spirits"), list("CallforChurchMeeting", "Call for Church Meeting"), list("Marriage", "Marriage!"), list("ClearName", "Clear Name"))
		if(H.job == "Monk" || H.old_job == "Monk")
			verbs += list(list("BannishtheUndead", "Banish Undead"), list("RobofSins", "Rob of Sins"), list("Eucharisty", "Eucharisty"), list("BannishSpirits", "Banish Spirits"), list("Marriage", "Marriage"))
		if(H.job == "Expedition Leader" || H.old_job == "Expedition Leader")
			verbs += list(list("SetMigSpawn", "Set Migrant Arrival"), list("announceEx", "Announce (14 TILES)"))

		if(H.job == "Bum" || H.old_job == "Bum")
			verbs += list(list("tellTheTruth", "Tell the Truth"))

		if(H.job == "Urchin" || H.old_job == "Urchin")
			verbs += list(list("tellTheTruth", "Tell the Truth"))

		if(H.job == "Migrant" || H.old_job == "Migrant")
			if(!H.migclass)
				verbs += list(list("ChoosemigrantClass", "Choose Migrant Class!"))
				if(ckey in outlaw)
					verbs += list(list("ToggleOutlaw", "Toggle Outlaw!"))

		if(H.job == "Count" || H.old_job == "Count")
			verbs += list(list("Reinforcement" , "Change Reinforcement Type"), list("Command", "Command"), list("SpecialReinforcement", "Call for Special Reinforcement!"), list("Recruit", "Recruit"), list("CaptureThrone", "Capture Throne"))

		if(H.job == "Count Hand" || H.old_job == "Count Hand")
			verbs += list(list("Command", "Command"), list("SpecialReinforcement", "Call for Special Reinforcement!"), list("Recruit", "Recruit"))

		if(H.job == "Count Heir" || H.old_job == "Count Heir")
			verbs += list(list("SpecialReinforcement", "Call for Special Reinforcement!"))

		if(H.job == "Sieger" || H.old_job == "Sieger")
			if(!H.migclass)
				verbs += list(list("ChoosesiegerClass", "Choose Sieger Class!"))

		if(H.job == "Mercenary" || H.old_job == "Mercenary")
			if(!H.migclass)
				verbs += list(list("PegaclasseMerc", "Choose Mercenary Class!"))


		if(H.consyte)
			verbs += list(list("Choir", "Choir"), list("Respark", "Respark"))
		if(H.job == "Jester")
			verbs += list(list("joke", "Joke"), list("rememberjoke", "Remember Joke"),list("apelidar", "Give a Nickname!"), list("malabares", "Juggling!"))
		if(H.check_perk(/datum/perk/pathfinder))
			verbs += list(list("TrackSomeonePathFinder", "Track Someone"), list("TrackselfPathfinder", "Track Yourself"))
		if(H.check_perk(/datum/perk/singer))
			verbs += list(list("RememberSong", "Remember Song"), list("Sing", "Sing"))
*/

		if(H.verbs.Find(/mob/living/proc/interrogate))
			verbs += list(list("Interrogate", "Interrogate"))

	newOption = generateVerbList(verbs)
	return {"<span class='segment1'>[newOption]</span>"}

/client/proc/lobbyPig()
	src << browse('code/porco/html/pig.html', "window=outputwindow.browser; size=411x330;")

/mob/proc/defaultButton()
	client.changebuttoncontent("#options", "<span class='segment1'>" + generateVerbList(list(list("OOC", "OOC"), list("Adminhelp", "Admin Help"), list("ShowAchievements", "Show Achievements"))) + "</span>")

/client/proc/setDefaultButtons()
	changebuttoncontent("#Verb", {"<span class='segment1'>[generateVerbList(list(list("DisguiseVoice", "Disguise Voice"), list("Dance", "Dance"), list("Pee", "Pee"), list("Poo", "Poo")))]</span>"} + {"<span class='segment2'>[generateVerbList(list(list("Notes", "Memories"), list("Pray", "Pray"), list("AddNote", "Add Memories"), list("ShowGoals", "Show Goals")))]</span>"})

/client/New()
	..()
	loadDataPig()
	lobbyPig()

	if(!holder)
		return
	winset(src, "outputwindow.csay", "is-visible=true")

/mob/new_player/say(message)
	if(!client)
		return

	client.ooc(message)

/mob/verb/soundbutton()
	set hidden = 1
	set name = "button"

	client << 'sound/uibutton.ogg'

/mob/verb/heartporcao()
	set hidden = 1
	set name = "heartpig"

	soundbutton()

/mob/proc/updateStatPig()
	if(!client)
		return
	if(!client.pigReady)
		return

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		client << output(list2params(list("#st", "[H.stats[STAT_ST]]")), "outputwindow.browser:change")
		client << output(list2params(list("#ht", "[H.stats[STAT_HT]]")), "outputwindow.browser:change")
		client << output(list2params(list("#int", "[H.stats[STAT_IQ]]")), "outputwindow.browser:change")
		client << output(list2params(list("#dx", "[H.stats[STAT_DX]]")), "outputwindow.browser:change")

/*
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		client << output(list2params(list("#pr", "[H.my_stats.pr]")), "outputwindow.browser:change")
		client << output(list2params(list("#timepusher", "[src?:mind?.time_to_pay]")), "outputwindow.browser:change")
		client << output(list2params(list("#im", "[H.my_stats.im]")), "outputwindow.browser:change")
		client << output(list2params(list("#wp", "[H.my_stats.wp]")), "outputwindow.browser:change")
*/

/mob/proc/pigHandler()
	updatePig()
	if(!ishuman(src))
		return

	var/mob/living/carbon/human/H = src
	H.updateStatPig()

/mob/living/carbon/human/New()
	..()

/mob/proc/startPig()
	spawn while(client)
		sleep(85)
		pigHandler()
		updateStatPig()

/mob/living/carbon/human/Login()
	..()
	heartporcao()
	updatePig()
	startPig()