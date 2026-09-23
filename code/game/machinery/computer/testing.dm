/obj/machinery/computer/testing
	name = "testing computer"
	desc = "I fucking hate you."
	var/dispensed = 0 //why yes, I am stealing this from the nano code, how could you t-ACK!
	var/centcomm_message_cooldown = 0
	var/announcment_cooldown = 0
	var/datum/announcement/priority/crew_announcement = new
	var/current_viewing_message_id = 0
	var/current_viewing_message = null
	var/new_sound = 'sound/machines/announce_alarm.ogg'
	var/new_sound_red = 'sound/machines/announce_alarm_red.ogg'

/obj/machinery/computer/testing/Topic(href, href_list, hsrc)
	..()
	if(get_dist(src, usr) > 1)
		return
	switch(href_list["action"])
		if("printstatus")
			if(!dispensed)
				if(get_dist(src, usr) > 1)
					return
				src.audible_message("The computer makes a few noises as it dispenses a piece of paper.")
				playsound(src, 'sound/machines/dotprinter.ogg', 10, 1)
				var/obj/item/weapon/paper/R = new(src.loc)
				R.set_content("<b>LOG 22-10-2167</b>\n\nREPORT\n\nTHE MUSSR HAS FALLEN DOT\n\nRETURN TO DAILY ACTIVITY DOT\n\n<b>LOG 12-12-2188</b>\n\nCRYOGENIC STORAGE ACCESS DENIED DOT\n\nACTIVATING CONSERVATION MODE DOT\n\n<b>LOG 18-07-2258</b>\n\nISHIM REPUBLIC IN FULL ALERT STATE DOT\n\nREQUESTING HELP DOT\n\n<b>LOG 19-10-2263</b>\n\nTHE DOT STATION DOT IS DOT UNDER DOT TETRACORP DOT COMMAND DOT\n\nACTIVATE DOT CRYOGENIC DOT AWAKENING DOT")
				var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
				stampoverlay.icon_state = "paper_stamp-hos"
				R.stamped += /obj/item/weapon/stamp
				R.overlays += stampoverlay
				R.stamps += "<HR><i>This paper has been stamped as 'Top Secret'.</i>"
				dispensed = 1
			else
				to_chat(usr, "<span class='warning'>The computer lets out a soft beep as it fails to dispense the status report. Maybe it's out of paper? Piece of shit never gets stocked.</span>")
		if("checkstationintegrity")
			playsound(src, 'sound/machines/TERMINAL_DAT.ogg', 10, 1, -2)
			to_chat(usr, "<span class='warning'></b> &@&# ERR### ARRAY OFFLINE, PL333E CONTACT LOCAL ENGINEERING DEPARTMENT HEAD #$$@%) </span></b>")
		if("announce")
			if(usr)
				var/obj/item/weapon/card/id/id_card = usr.GetIdCard()
				crew_announcement.announcer = GetNameAndAssignmentFromId(id_card)
			else
				crew_announcement.announcer = "Unknown"
			if(announcment_cooldown)
				to_chat(usr, "Please allow at least one minute to pass between announcements.")
				return TRUE
			var/input = input(usr, "Please write a message to announce to the [station_name()].", "Priority Announcement") as null|message
			if(!input || get_dist(src, usr) > 1)
				return 1
			if(GLOB.in_character_filter.len)
				if(findtext(input, config.ic_filter_regex))
					to_chat(usr, "<span class='warning'>You rethink your decision and decide that Tetracorp will fire you if you announce that.</span>")
					return 1
			var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
			var/decl/security_level/default/df = security_state.current_security_level
			if(df.code == GREEN_CODE)
				crew_announcement.Announce(input, new_sound = 'sound/machines/announce_alarm.ogg')
				announcment_cooldown = 1
			else if(df.code == RED_CODE)
				crew_announcement.Announce(input, new_sound = 'sound/machines/announce_alarm_red.ogg')
				announcment_cooldown = 1
			spawn(600)//One minute cooldown
				announcment_cooldown = 0

/obj/machinery/computer/testing/attack_hand(mob/user)
	..()
	if(stat & (BROKEN|NOPOWER))
		return
	to_chat(user, "\n<div class='firstdivmood'><div class='moodbox'><span class='graytext'>The computer's nearly burned out screen shows you the following commands:</span>\n<hr><span class='feedback'><a href='byond://?src=\ref[src];action=printstatus;align='right'>PRINT LATEST COMMUNICATION LOGS</a></span>\n<span class='feedback'><a href='byond://?src=\ref[src];action=checkstationintegrity;align='right'>STATION STATUS</a></span>\n<span class='feedback'><a href='byond://?src=\ref[src];action=announce;align='right'>SEND AN ANNOUNCEMENT</a></span></div></div>")