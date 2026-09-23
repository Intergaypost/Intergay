//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/priority_air_alarms = list()
var/global/list/minor_air_alarms = list()


/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the atmospheric sensors."
	circuit = /obj/item/weapon/circuitboard/atmos_alert
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = "#e6ffff"

/obj/machinery/computer/atmos_alert/Initialize()
	. = ..()
	atmosphere_alarm.register_alarm(src, TYPE_PROC_REF(/atom, update_icon))

/obj/machinery/computer/atmos_alert/Destroy()
	atmosphere_alarm.unregister_alarm(src)
	. = ..()

/obj/machinery/computer/atmos_alert/Process()
	..()

/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	var/data[0]
	var/major_alarms[0]
	var/minor_alarms[0]
	var/msg = "<div class='firstdivskill'><div class='skilldiv'><hr class='linexd'>"

	for(var/datum/alarm/alarm in atmosphere_alarm.major_alarms(get_z(src)))
		major_alarms[++major_alarms.len] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	for(var/datum/alarm/alarm in atmosphere_alarm.minor_alarms(get_z(src)))
		minor_alarms[++minor_alarms.len] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	data["priority_alarms"] = major_alarms
	data["minor_alarms"] = minor_alarms

	msg += "<H1>Priority Alerts</H1>"

	if(major_alarms.len)
		for(var/zone in major_alarms)
			msg += "<FONT color='red'><B>[zone]</B></FONT> <a href='byond://?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
	else
		msg += "No priority alerts detected.<BR>"

	msg += "<H1>Minor Alerts</H1>"

	if(minor_alarms.len)
		for(var/zone in minor_alarms)
			msg += "<B>[zone]</B> <a href='byond://?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
	else
		msg += "No minor alerts detected.<BR>"

	msg += "</div></div>"

	to_chat(usr, msg)

/obj/machinery/computer/atmos_alert/update_icon()
	if(!(stat & (NOPOWER|BROKEN)))
		if(atmosphere_alarm.has_major_alarms(get_z(src)))
			icon_screen = "alert:2"
		else if (atmosphere_alarm.has_minor_alarms(get_z(src)))
			icon_screen = "alert:1"
		else
			icon_screen = initial(icon_screen)
	..()

var/datum/topic_state/air_alarm_topic/air_alarm_topic = new()

/datum/topic_state/air_alarm_topic/href_list(var/mob/user)
	var/list/extra_href = list()
	extra_href["remote_connection"] = 1
	extra_href["remote_access"] = 1

	return extra_href

/obj/machinery/computer/totalpower // so true queen
	name = "total power computer"
	desc = "Used to know information about the power grid."
	//circuit = /obj/item/weapon/circuitboard/totalpower //later
	icon_screen = "power_screen"
	light_color = "#e6ffff"
	var/datum/powernet/powernet = null

/obj/machinery/computer/totalpower/Process()
	..()

// Proc: reading_to_text()
// Parameters: 1 (amount - Power in Watts to be converted to W, kW or MW)
// Description: Helper proc that converts reading in Watts to kW or MW (returns string version of amount parameter)
/obj/machinery/computer/totalpower/proc/reading_to_text(var/amount = 0)
	var/units = ""
	// 10kW and less - Watts
	if(amount < 10000)
		units = "W"
	// 10MW and less - KiloWatts
	else if(amount < 10000000)
		units = "kW"
		amount = (round(amount/100) / 10)
	// More than 10MW - MegaWatts
	else
		units = "MW"
		amount = (round(amount/10000) / 100)
	if (units == "W")
		return "[amount] W"
	else
		return "~[amount] [units]" //kW and MW are only approximate readings, therefore add "~"

// Proc: find_apcs()
// Parameters: None
// Description: Searches powernet for APCs and returns them in a list.
/obj/machinery/computer/totalpower/proc/find_apcs()
	if(!powernet)
		return

	var/list/L = list()
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		if(istype(term.master, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = term.master
			L += A

	return L


// Proc: return_reading_text()
// Parameters: None
// Description: Generates string which contains HTML table with reading data.
/obj/machinery/computer/totalpower/proc/return_reading_text()
	var/msg = "\n<div class='firstdiv'><div class='box'>"

	var/total_apc_load = 0

	// Split to multiple lines to make it more readable
	for(var/obj/machinery/power/apc/A in world)
		var/load = A.lastused_total // Load.
		total_apc_load += load
		load = reading_to_text(load)
		msg += "<br>[load]"

	msg += "<br>POWER GRID STATUS:\n"
	msg += "<hr class='linexd'>"
	msg += "<br><b>TOTAL AVAILABLE: [reading_to_text(powernet.avail)]</b>\n"
	msg += "<br><b>APC LOAD: [reading_to_text(total_apc_load)]</b>\n"
	msg += "<br><b>OTHER LOAD: [reading_to_text(max(powernet.load - total_apc_load, 0))]</b>\n"
	msg += "<br><b>TOTAL GRID LOAD: [reading_to_text(powernet.viewload)] ([round((powernet.load / powernet.avail) * 100)]%)</b>\n"

	if(powernet.problem)
		msg += "<br><b>WARNING: Abnormal grid activity detected!</b>"
	msg += "</div></div>"
	to_chat(src, msg)

/obj/machinery/computer/totalpower/attack_hand(mob/user)
	..()
	if(ishuman(src))
		return_reading_text()