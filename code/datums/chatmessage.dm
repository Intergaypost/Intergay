/client/var/list/seen_messages

/**
 * # Chat Message Overlay (Runechat)
 *
 * Datum for generating an animated floating chat overlay message on the map.
 */
/datum/chatmessage
	/// The visual element of the chat message
	var/image/message
	/// The target atom to display the overlay at
	var/atom/target
	/// The client who saw/heard this message
	var/client/owned_by
	/// Contains the approximate amount of lines for height decay
	var/approx_lines = 1
	/// The current index used for adjusting the layer of each sequential chat message
	var/static/current_z_idx = 0
	/// When we started animating the message
	var/animate_start = 0
	/// Our animation lifespan, how long this message will last
	var/animate_lifespan = 0

/**
 * Constructs a chat message overlay
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The mob that owns this overlay, only this mob will be able to view it
 * * language - The language this message was spoken in
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/chatmessage/New(text, atom/target, mob/owner, datum/language/language, list/extra_classes = list(), lifespan = CHAT_MESSAGE_LIFESPAN)
	..()
	if(!istype(target))
		qdel(src)
		return
	if(!owner || !owner.client)
		qdel(src)
		return
	src.target = target
	src.owned_by = owner.client
	generate_image(text, target, owner, language, extra_classes, lifespan)

/datum/chatmessage/Destroy()
	if(owned_by)
		if(owned_by.seen_messages && target)
			var/list/cur_messages = owned_by.seen_messages[target]
			if(islist(cur_messages))
				cur_messages -= src
				if(!cur_messages.len)
					owned_by.seen_messages -= target
		if(message)
			owned_by.images -= message

	owned_by = null
	target = null
	message = null
	return ..()

/**
 * Generates a chat message image representation
 */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, datum/language/language, list/extra_classes, lifespan)
	// Clean up any legacy &#255;, &#1103;, &yuml;, or ÿ to UTF-8
	text = replacetext(text, ("&" + "#255;"), "я")
	text = replacetext(text, ("&" + "#1103;"), "я")
	text = replacetext(text, "&yuml;", "я")
	text = replacetext(text, "ÿ", "я")
	text = replacetext(text, ascii2text(255), "я")

	// Strip HTML tags from text
	var/static/regex/html_strip = regex("<\[^>\]*>", "gi")
	text = html_strip.Replace(text, "")

	// Clip message length
	if(length(text) > CHAT_MESSAGE_MAX_LENGTH)
		text = copytext(text, 1, CHAT_MESSAGE_MAX_LENGTH + 1) + "..."

	// Reject whitespace-only
	var/static/regex/whitespace = regex("^\\s*$")
	if(whitespace.Find(text))
		qdel(src)
		return

	if(!extra_classes)
		extra_classes = list()

	// Non-mob speakers can have smaller text
	if(!ismob(target))
		extra_classes |= "small"

	// Check yelling
	if(copytext(text, -2) == "!!")
		extra_classes |= "bold"

	// Resolve speaker color
	var/chat_color_name_to_use = target.name
	if(ismob(target))
		var/mob/M = target
		chat_color_name_to_use = M.name

	if(!target.chat_color || target.chat_color_name != chat_color_name_to_use)
		target.chat_color = colorize_string(chat_color_name_to_use)
		target.chat_color_darkened = colorize_string(chat_color_name_to_use, 0.5, 0.5)
		target.chat_color_name = chat_color_name_to_use

	var/tgt_color = (extra_classes.Find("italics")) ? target.chat_color_darkened : target.chat_color
	var/isemote = (extra_classes.Find("emote")) ? "*" : ""
	var/isbold = (extra_classes.Find("bold")) ? "font-weight: bolder;" : ""
	var/isitalic = (extra_classes.Find("italics")) ? "font-style: italic;" : ""
	var/issmall = (extra_classes.Find("small")) ? "font-size: small;" : ""

	var/complete_text = "<span style='color: [tgt_color]; font-family: Arial, sans-serif; font-size: 7pt; text-align: center; -dm-text-outline: 1px #000000; line-height: 1.1;'><span style='[isbold] [isitalic] [issmall]'>[isemote] [text]</span></span>"

	var/mheight = 0
	if(owned_by)
		var/measured = owned_by.MeasureText(complete_text, "font-family: Arial, sans-serif; font-size: 7pt;", CHAT_MESSAGE_WIDTH)
		if(measured && istext(measured))
			var/x_pos = findtext(measured, "x")
			if(x_pos)
				mheight = text2num(copytext(measured, x_pos + 1))

	if(!mheight)
		var/line_count = max(1, round(length(text) / 22) + 1)
		mheight = line_count * CHAT_MESSAGE_APPROX_LHEIGHT

	finish_image_generation(mheight, target, owner, complete_text, lifespan)

/**
 * Finishes the image generation and applies animations
 */
/datum/chatmessage/proc/finish_image_generation(mheight, atom/target, mob/owner, complete_text, lifespan)
	if(!owned_by || !target)
		qdel(src)
		return

	var/rough_time = world.time
	approx_lines = max(1, round(mheight / CHAT_MESSAGE_APPROX_LHEIGHT))
	var/starting_height = 32
	if(ismob(target))
		var/mob/M = target
		starting_height = max(32, M.bound_height)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	if(owned_by.seen_messages && owned_by.seen_messages[target])
		var/idx = 1
		var/combined_height = approx_lines
		for(var/datum/chatmessage/m in owned_by.seen_messages[target])
			if(!m || !m.message)
				continue
			combined_height += m.approx_lines

			var/time_spent = rough_time - m.animate_start
			var/time_before_fade = m.animate_lifespan - CHAT_MESSAGE_EOL_FADE

			var/remaining_time = time_before_fade * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height)
			m.message.alpha = m.get_current_alpha(time_spent)

			if(remaining_time > 0)
				animate(m.message, alpha = 255, time = max(0, CHAT_MESSAGE_SPAWN_TIME - time_spent))
				animate(m.message, alpha = 255, time = remaining_time)
				animate(m.message, alpha = 0, time = CHAT_MESSAGE_EOL_FADE)
				m.animate_lifespan = remaining_time + CHAT_MESSAGE_EOL_FADE
			else
				animate(m.message, alpha = 0, time = CHAT_MESSAGE_EOL_FADE)

			animate(m.message, pixel_z = m.message.pixel_z + mheight, time = CHAT_MESSAGE_SPAWN_TIME)

	// Reset z index if needed
	if(current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	// Build message image
	message = image(loc = target, layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx++)
	message.plane = RUNECHAT_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART | RESET_COLOR
	message.alpha = 0
	message.pixel_z = starting_height
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = max(mheight + 14, 32)
	message.maptext_x = round((CHAT_MESSAGE_WIDTH - 32) * -0.5)
	message.maptext = "<center>[complete_text]</center>"

	animate_start = rough_time
	animate_lifespan = lifespan

	if(!owned_by.seen_messages)
		owned_by.seen_messages = list()
	if(!owned_by.seen_messages[target])
		owned_by.seen_messages[target] = list()
	owned_by.seen_messages[target] += src
	owned_by.images += message

	// Fade in
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)
	var/time_before_fade = max(0, lifespan - CHAT_MESSAGE_SPAWN_TIME - CHAT_MESSAGE_EOL_FADE)
	// Stay faded in
	animate(alpha = 255, time = time_before_fade)
	// Fade out
	animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)

	spawn(lifespan + CHAT_MESSAGE_GRACE_PERIOD)
		qdel(src)

/datum/chatmessage/proc/get_current_alpha(time_spent)
	if(time_spent < CHAT_MESSAGE_SPAWN_TIME)
		return (time_spent / CHAT_MESSAGE_SPAWN_TIME) * 255

	var/time_before_fade = animate_lifespan - CHAT_MESSAGE_EOL_FADE
	if(time_spent <= time_before_fade)
		return 255

	return (1 - ((time_spent - time_before_fade) / CHAT_MESSAGE_EOL_FADE)) * 255

/**
 * Creates a message overlay at a defined location for a given speaker
 *
 * Arguments:
 * * speaker - The atom who is saying this message
 * * message_language - The language that the message is said in
 * * raw_message - The text content of the message
 * * spans - Additional classes to be added to the message
 * * runechat_flags - Runechat flags (e.g. EMOTE_MESSAGE)
 */
/mob/proc/create_chat_message(atom/movable/speaker, datum/language/message_language, raw_message, list/spans = list(), runechat_flags = 0)
	if(!client)
		return
	if(client.get_preference_value(/datum/client_preference/show_runechat) != GLOB.PREF_SHOW)
		return
	if(!speaker || !raw_message)
		return
	if(!ismob(speaker) && client.get_preference_value(/datum/client_preference/show_runechat_non_mobs) != GLOB.PREF_SHOW)
		return
	if(isghost(speaker) && client.get_preference_value(/datum/client_preference/show_runechat_ghosts) != GLOB.PREF_SHOW)
		return
	if((runechat_flags & EMOTE_MESSAGE) && is_blind())
		return
	if(!(runechat_flags & EMOTE_MESSAGE) && is_deaf())
		return
	if(speaker.invisibility > see_invisible)
		return

	var/list/classes = (runechat_flags & EMOTE_MESSAGE) ? list("emote", "italics") : (islist(spans) ? spans.Copy() : list())

	new /datum/chatmessage(
		raw_message,
		speaker,
		src,
		message_language,
		classes,
		CHAT_MESSAGE_LIFESPAN
	)
