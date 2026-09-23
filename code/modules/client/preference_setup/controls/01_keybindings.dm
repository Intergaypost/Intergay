/// checks through keybindings for outdated unbound keys and updates them
/datum/preferences/proc/check_keybindings()
	if(!client)
		return

	// When loading from savefile key_binding can be null
	// This happens when player had savefile created before new kb system, but hotkeys was not saved
	if(!length(key_bindings))
		key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds too

	var/list/user_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)
	var/list/notadded = list()
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(length(user_binds[kb.name]))
			continue // key is unbound and or bound to something
		var/addedbind = FALSE
		if(hotkeys)
			for(var/hotkeytobind in kb.hotkey_keys)
				if(!length(key_bindings[hotkeytobind]) || hotkeytobind == "Unbound") //Only bind to the key if nothing else is bound expect for Unbound
					LAZYADD(key_bindings[hotkeytobind], kb.name)
					addedbind = TRUE
		else
			for(var/classickeytobind in kb.classic_keys)
				if(!length(key_bindings[classickeytobind]) || classickeytobind == "Unbound") //Only bind to the key if nothing else is bound expect for Unbound
					LAZYADD(key_bindings[classickeytobind], kb.name)
					addedbind = TRUE
		if(!addedbind)
			notadded += kb

	if(length(notadded))
		addtimer(CALLBACK(src, .proc/announce_conflict, notadded), 5 SECONDS)

/datum/preferences/proc/announce_conflict(list/notadded)
	to_chat(client, "<span class='danger'>KEYBINDING CONFLICT.\n\
	There are new keybindings that have defaults bound to keys you already set, They will default to Unbound. You can bind them in Setup Character or Game Preferences\n\
	<a href='?src=\ref[src];preference=tab;tab=3'>Or you can click here to go straight to the keybindings page.</a></span>")
	for(var/item in notadded)
		var/datum/keybinding/conflicted = item
		to_chat(client, "<span class='danger'>[conflicted.category]: [conflicted.full_name] needs updating.</span>")
		LAZYADD(key_bindings["None"], conflicted.name) // set it to unbound to prevent this from opening up again in the future

/datum/category_item/player_setup_item/controls/keybindings
	name = "Keybindings"
	sort_order = 1

/datum/category_item/player_setup_item/controls/keybindings/load_preferences(var/savefile/S)
	S["key_bindings"] >> pref.key_bindings
	S["hotkeys"] >> pref.hotkeys

/datum/category_item/player_setup_item/controls/keybindings/sanitize_preferences()
	pref.hotkeys = sanitize_integer(pref.hotkeys, 0, 1, initial(pref.hotkeys))
	pref.key_bindings = sanitize_keybindings(pref.key_bindings)
	pref.check_keybindings()

/datum/category_item/player_setup_item/controls/keybindings/save_preferences(var/savefile/S)
	S["key_bindings"] << pref.key_bindings
	S["hotkeys"] << pref.hotkeys

/datum/category_item/player_setup_item/controls/keybindings/get_data(var/mob/user)
	var/list/user_binds = list()
	for (var/key in pref.key_bindings)
		for(var/kb_name in pref.key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/categories_data = list()
	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(kb.admin && (!user || !user.client || !user.client.holder))
			continue
		kb_categories[kb.category] += list(kb)

	for (var/cat_name in kb_categories)
		var/list/bindings_data = list()
		for (var/datum/keybinding/kb in kb_categories[cat_name])
			var/list/bound_keys = list()
			var/list/current_keys = user_binds[kb.name]
			if(length(current_keys))
				for(var/k in current_keys)
					if(k == "None" && length(current_keys) == 1)
						continue
					var/display_k = GLOB._kbMap_reverse[k] ? GLOB._kbMap_reverse[k] : k
					bound_keys += list(list(
						"key" = k,
						"display_name" = display_k
					))

			var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
			var/is_default = (user_binds[kb.name] ~= default_keys) ? 1 : 0
			var/old_keys_str = length(current_keys) ? jointext(current_keys, ",") : ""

			bindings_data += list(list(
				"name" = kb.name,
				"full_name" = kb.full_name,
				"description" = kb.description,
				"keys" = bound_keys,
				"has_keys" = (length(bound_keys) > 0) ? 1 : 0,
				"can_add" = (length(bound_keys) < MAX_KEYS_PER_KEYBIND) ? 1 : 0,
				"is_default" = is_default,
				"old_keys_str" = old_keys_str
			))

		categories_data += list(list(
			"name" = cat_name,
			"bindings" = bindings_data
		))

	return list(
		"ref" = "\ref[src]",
		"hotkeys" = pref.hotkeys ? 1 : 0,
		"examine_cursor" = (user && user.client && user.client.get_preference_value(/datum/client_preference/examine_cursor) == GLOB.PREF_YES) ? 1 : 0,
		"categories" = categories_data
	)

/datum/category_item/player_setup_item/controls/keybindings/content(mob/user)
	. = list()
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for (var/key in pref.key_bindings)
		for(var/kb_name in pref.key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(kb.admin && (!user || !user.client || !user.client.holder))
			continue
		kb_categories[kb.category] += list(kb)

	var/examine_cursor_pref = user?.client ? user.client.get_preference_value(/datum/client_preference/examine_cursor) : GLOB.PREF_YES
	. += "<center>"
	. += "<b>Examine Cursor (Shift-hover):</b> <a href='?src=\ref[src];toggle_examine_cursor=1'><b>[examine_cursor_pref]</b></a><br><br>"
	. += "<div class='statusDisplay'>"

	for (var/category in kb_categories)
		. += "<h3>[category]</h3>"
		. += "<table width='100%'>"
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]) || (user_binds[kb.name][1] == "None" && length(user_binds[kb.name]) == 1))
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=None'>None</a></td>"
				var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
				var/class
				if(user_binds[kb.name] ~= default_keys)
					class = "class='linkOff fluid'"
				else
					class = "class='fluid' href ='?src=\ref[src];preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]'"

				. += "<td width='15%'></td><td width='15%'></td><td width='15%'><a [class]>Reset</a></td>"
				. += "</tr>"
			else
				var/bound_key = user_binds[kb.name][1]
				var/normal_name = GLOB._kbMap_reverse[bound_key] ? GLOB._kbMap_reverse[bound_key] : bound_key
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[normal_name]</a></td>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					normal_name = GLOB._kbMap_reverse[bound_key] ? GLOB._kbMap_reverse[bound_key] : bound_key
					. += "<td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[normal_name]</a></td>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					. += "<td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name]'>None</a></td>"
				for(var/j in 1 to MAX_KEYS_PER_KEYBIND - (length(user_binds[kb.name]) + 1))
					. += "<td width='15%'></td>"
				var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
				. += "<td width='15%'><a [user_binds[kb.name] ~= default_keys ? "class='linkOff fluid'" : "class='fluid' href ='?src=\ref[src];preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]'"]>Reset</a></td>"
				. += "</tr>"
		. += "</table>"

	. += "</div>"
	. += "<br><br>"
	. += "<a href ='?src=\ref[src];preference=keybindings_reset'>Reset to default</a>"
	. += "</center>"

	return jointext(., null)

/datum/category_item/player_setup_item/controls/keybindings/proc/capture_keybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div class='Section fill'id='focus' style="outline: 0; text-align:center;" tabindex=0>
		Keybinding: [kb.full_name]<br>[kb.description]
		<br><br>
		<b>Press any key to change<br>Press ESC to clear</b>
	</div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var sanitizedKey = e.key;
		if (47 < e.keyCode && e.keyCode < 58) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		else if (64 < e.keyCode && e.keyCode < 91) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		var url = 'byond://?src=\ref[src];preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+sanitizedKey+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/category_item/player_setup_item/controls/keybindings/OnTopic(href, list/href_list, mob/user)
	if(href_list["toggle_hotkeys"])
		pref.hotkeys = !pref.hotkeys
		if(user?.client)
			user.client.set_macros()
		return TOPIC_REFRESH

	if(href_list["fix_macros"])
		if(user?.client)
			user.client.reset_macros(skip_alert = TRUE)
		return TOPIC_REFRESH

	if(href_list["toggle_examine_cursor"])
		var/current_val = user?.client ? user.client.get_preference_value(/datum/client_preference/examine_cursor) : GLOB.PREF_YES
		var/new_val = (current_val == GLOB.PREF_YES) ? GLOB.PREF_NO : GLOB.PREF_YES
		user?.set_preference(/datum/client_preference/examine_cursor, new_val)
		return TOPIC_REFRESH


	switch(href_list["preference"])
		if("keybindings_capture")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
			var/old_key = href_list["old_key"]
			capture_keybinding(user, kb, old_key)
			return TOPIC_REFRESH

		if("keybindings_set")
			var/kb_name = href_list["keybinding"]
			if(!kb_name)
				show_browser(user, null, "window=capturekeypress")
				return TOPIC_REFRESH

			var/clear_key = text2num(href_list["clear_key"])
			var/old_key = href_list["old_key"]
			if(clear_key)
				if(pref.key_bindings[old_key])
					pref.key_bindings[old_key] -= kb_name
					if(!(kb_name in pref.key_bindings["None"]))
						LAZYADD(pref.key_bindings["None"], kb_name)
					if(!length(pref.key_bindings[old_key]))
						pref.key_bindings -= old_key
				show_browser(user, null, "window=capturekeypress")
				if(user?.client)
					user.client.set_macros()
				return TOPIC_REFRESH

			var/new_key = uppertext(href_list["key"])
			var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
			var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
			var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
			var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""

			if(!new_key) // Just in case (; - not work although keyCode 186 and nothing should break)
				show_browser(user, null, "window=capturekeypress")
				return TOPIC_REFRESH

			if(GLOB._kbMap[new_key])
				new_key = GLOB._kbMap[new_key]

			var/full_key
			switch(new_key)
				if("Alt")
					full_key = "[new_key][CtrlMod][ShiftMod]"
				if("Ctrl")
					full_key = "[AltMod][new_key][ShiftMod]"
				if("Shift")
					full_key = "[AltMod][CtrlMod][new_key]"
				else
					full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
			if(kb_name in pref.key_bindings[full_key]) //We pressed the same key combination that was already bound here, so let's remove to re-add and re-sort.
				pref.key_bindings[full_key] -= kb_name
			if(pref.key_bindings[old_key])
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key
			pref.key_bindings[full_key] += list(kb_name)
			pref.key_bindings[full_key] = sortTim(pref.key_bindings[full_key], /proc/cmp_text_asc)

			show_browser(user, null, "window=capturekeypress")
			if(user?.client)
				user.client.set_macros()
			return TOPIC_REFRESH

		if("keybindings_reset")
			pref.key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
			if(user?.client)
				user.client.set_macros()
			return TOPIC_REFRESH

		if("keybinding_reset")
			var/kb_name = href_list["keybinding"]
			var/list/old_keys = splittext(href_list["old_keys"], ",")

			for(var/old_key in old_keys)
				if(!pref.key_bindings[old_key])
					continue
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key

			var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
			var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
			for(var/key in default_keys)
				pref.key_bindings[key] += list(kb_name)
				pref.key_bindings[key] = sortTim(pref.key_bindings[key], /proc/cmp_text_asc)
			if(user?.client)
				user.client.set_macros()
			return TOPIC_REFRESH

	return ..()

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value, list())
	for(var/key in base_bindings)
		base_bindings[key] = base_bindings[key] & GLOB.keybindings_by_name
		if(!length(base_bindings[key]))
			base_bindings -= key
	return base_bindings
