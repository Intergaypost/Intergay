/*
	========================================================================================
	VERB MANAGER & SUBSYSTEM CONTROLLER
	========================================================================================

	HOW TO ADD NEW VERBS TO THE CATALOG:
	In get_all_verb_definitions(), add a line using the appropriate macro:

	1. Standard verb (command name matches display name):
	   ADD_VERB("Verb Name", "Category", "Short description")
	   Example: ADD_VERB("Admin Ghost", "Admin", "Ghost freely while keeping your physical body")

	2. Custom command name (differs from display name):
	   ADD_VERB_CMD("Display Name", "BYOND-Command-Name", "Category", "Short description")
	   Example: ADD_VERB_CMD("View Variables (VV)", "View-Variables", "Debug", "Inspect variables of any atom or datum")

	Available categories: "Admin", "Debug", "Server", "Fun", "Spawn", "Mapping", "Special"
	========================================================================================
*/

/datum/admins
	var/vm_screen = 1
	var/vm_category = "All"
	var/vm_search = ""
	var/mc_updating = FALSE

/datum/admins/proc/open_verb_manager()
	set category = "Admin"
	set name = "Verb Manager"
	set desc = "Open the interactive Verb Manager and Master Controller panel (NanoUI)."

	if(!check_rights(0))
		return

	ui_interact(usr)

/datum/admins/proc/mc_update_loop(client/C)
	set waitfor = 0
	if(mc_updating)
		return
	mc_updating = TRUE
	while(C && C.holder == src && vm_screen == 3)
		var/datum/nanoui/ui = SSnano.get_open_ui(C.mob, src, "verb_manager")
		if(!ui)
			break
		ui_interact(C.mob, force_open = 0)
		sleep(5) // 0.5 seconds (5 deciseconds)
	mc_updating = FALSE

/datum/admins/ui_interact(mob/user, ui_key = "verb_manager", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/nanoui/master_ui = null, var/datum/topic_state/state = GLOB.admin_state)
	if(!check_rights(0, 0, user))
		return

	var/list/data = list()
	data["screen"] = vm_screen
	data["categories"] = list("All", "Admin", "Debug", "Server", "Fun", "Spawn", "Mapping", "Special")
	data["selected_category"] = vm_category
	data["search_query"] = vm_search

	// 1. Verbs list
	var/list/all_verbs = get_all_verb_definitions(user)
	var/list/filtered_verbs = list()
	for(var/list/V in all_verbs)
		var/vname = V["name"]
		var/vcat = V["cat"]
		var/vdesc = V["desc"]

		if(vm_category != "All" && vcat != vm_category)
			continue
		if(vm_search && !findtext(vname, vm_search) && !findtext(vdesc, vm_search) && !findtext(vcat, vm_search))
			continue
		filtered_verbs += list(V)

	data["verbs"] = filtered_verbs

	// 2. User info
	data["user_info"] = list(
		"ckey" = user.ckey,
		"rank" = rank ? rank : "*None*",
		"rights" = rights2text(rights, ", "),
		"stealth" = stealthy_ ? 1 : 0
	)

	// 3. MC info
	var/master_str = "NOT RUNNING"
	var/master_ref = null
	if(Master)
		master_str = "TickRate: [Master.processing] | Iteration: [Master.iteration] | TickLimit: [round(Master.current_ticklimit, 0.1)]"
		master_ref = "\ref[Master]"

	var/failsafe_str = "NOT RUNNING"
	var/failsafe_ref = null
	if(Failsafe)
		failsafe_str = "Defcon: [Failsafe.defcon_pretty()] | Interval: [Failsafe.processing_interval] | Iteration: [Failsafe.master_iteration]"
		failsafe_ref = "\ref[Failsafe]"

	data["mc_info"] = list(
		"cpu" = world.cpu,
		"fps" = world.fps,
		"instances" = world.contents.len,
		"tickdrift" = Master ? "[round(Master.tickdrift, 1)] ([round((Master.tickdrift / (world.time / world.tick_lag)) * 100, 0.1)]%)" : "0",
		"internal_tick" = round(MAPTICK_LAST_INTERNAL_TICK_USAGE, 0.1),
		"round_time" = round(world.time / 10),
		"master_status" = master_str,
		"master_ref" = master_ref,
		"failsafe_status" = failsafe_str,
		"failsafe_ref" = failsafe_ref
	)

	var/list/subsystems_data = list()
	if(Master && Master.subsystems)
		for(var/datum/controller/subsystem/SS in Master.subsystems)
			var/state_text = "IDLE"
			switch(SS.state)
				if(SS_IDLE) state_text = "IDLE"
				if(SS_QUEUED) state_text = "QUEUED"
				if(SS_RUNNING) state_text = "RUNNING"
				if(SS_PAUSED) state_text = "PAUSED"
				if(SS_SLEEPING) state_text = "SLEEPING"
			subsystems_data += list(list(
				"name" = SS.name,
				"init" = SS.stat_entry_init(),
				"cost" = round(SS.cost, 0.001),
				"tick" = round(SS.tick_usage, 0.1),
				"state" = state_text,
				"can_fire" = SS.can_fire,
				"times_fired" = SS.times_fired,
				"ref"  = "\ref[SS]"
			))
	data["subsystems"] = subsystems_data

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "verb_manager.tmpl", "Verb Manager & Control Panel", 850, 650, state = state)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

	if(vm_screen == 3 && user.client && !mc_updating)
		mc_update_loop(user.client)


// Verb definitions catalog list (includes curated definitions + automatic discovery of all other verbs)
/datum/admins/proc/get_all_verb_definitions(mob/user = null)
	var/list/res = list()
	var/list/known_by_cmd = list()

	#define ADD_VERB(NAME, CAT, DESC) \
		do { \
			var/cmd_k = replacetext(NAME, " ", "-"); \
			res += list(list("name" = (NAME), "cmd" = cmd_k, "cat" = (CAT), "desc" = (DESC))); \
			known_by_cmd[lowertext(cmd_k)] = TRUE; \
			known_by_cmd[lowertext(replacetext(NAME, " ", "_"))] = TRUE; \
			known_by_cmd[lowertext(NAME)] = TRUE; \
		} while(FALSE)

	#define ADD_VERB_CMD(NAME, CMD, CAT, DESC) \
		do { \
			res += list(list("name" = (NAME), "cmd" = (CMD), "cat" = (CAT), "desc" = (DESC))); \
			known_by_cmd[lowertext(CMD)] = TRUE; \
			known_by_cmd[lowertext(replacetext(CMD, "-", " "))] = TRUE; \
			known_by_cmd[lowertext(replacetext(CMD, "-", "_"))] = TRUE; \
			known_by_cmd[lowertext(NAME)] = TRUE; \
		} while(FALSE)

	// Admin Category
	ADD_VERB("Player Panel New", "Admin", "Главная панель управления игроками, муты, баны, телепорты")
	ADD_VERB_CMD("Player Panel (Legacy)", "Player-Panel", "Admin", "Индивидуальная панель управления игроками")
	ADD_VERB("Admin Ghost", "Admin", "Переход в режим призрака с сохранением тела")
	ADD_VERB("Stealth Mode", "Admin", "Скрыть свой ник в списках админов и чате")
	ADD_VERB_CMD("Secrets Panel", "Secrets", "Admin", "Меню секретов, глобальных ивентов и фановых настроек")
	ADD_VERB("Permissions Panel", "Admin", "Управление правами и рангами администраторов")
	ADD_VERB("Invisimin", "Admin", "Сделать своего моба невидимым для игроков")
	ADD_VERB_CMD("Admin Say (ASAY)", "Admin-Say", "Admin", "Отправить сообщение в админский OOC чат")
	ADD_VERB("Admin PM", "Admin", "Отправить приватное сообщение игроку")
	ADD_VERB("Check Antagonists", "Admin", "Список активных антагонистов раунда")
	ADD_VERB_CMD("Call Shuttle", "Admin-Call-Shuttle", "Admin", "Принудительно вызвать эвакуационный шаттл")
	ADD_VERB_CMD("Cancel Shuttle", "Admin-Cancel-Shuttle", "Admin", "Отменить вызов эвакуационного шаттла")
	ADD_VERB("Manage Silicon Laws", "Admin", "Просмотр и редактирование законов ИИ и боргов")
	ADD_VERB("Change Security Level", "Admin", "Изменить код тревоги (Green, Blue, Red, Delta)")
	ADD_VERB_CMD("Admin Rejuvenate", "Respawn-Character", "Admin", "Воскресить и восстановить персонажа")
	ADD_VERB("Free Job Slot", "Admin", "Освободить слот выбранной профессии в раунде")
	ADD_VERB("Game Panel", "Admin", "Панель текущего режима игры")
	ADD_VERB_CMD("Personal Lockers", "Admin-Personal-Lockers", "Admin", "Управление персональными шкафчиками игроков")

	// Debug Category
	ADD_VERB_CMD("View Variables (VV)", "View-Variables", "Debug", "Инспектор переменных любого объекта или датума")
	ADD_VERB("Debug Global Variables", "Debug", "Просмотр и редактирование глобальных переменных")
	ADD_VERB("MC Panel", "Debug", "Мониторинг Master Controller и подсистем")
	ADD_VERB("Call Proc", "Debug", "Вызов любой глобальной процедуры или метода")
	ADD_VERB("Call Proc on Target", "Debug", "Вызов процедуры на конкретном объекте")
	ADD_VERB_CMD("Enable Debug Verbs", "Debug-verbs", "Debug", "Включить расширенные маппинг и дебаг инструменты")
	ADD_VERB_CMD("Hide Debug Verbs", "Hide-Debug-verbs", "Debug", "Отключить расширенные дебаг инструменты")
	ADD_VERB("Air Report", "Debug", "Диагностика атмосферы и газовых смесей на карте")
	ADD_VERB("ZAS Settings", "Debug", "Настройки атмосферной системы ZAS")
	ADD_VERB("Reload Admins", "Debug", "Перезагрузить права администраторов из конфигурации")
	ADD_VERB("Restart Controller", "Debug", "Перезапустить Master или Failsafe контроллер")
	ADD_VERB("SDQL Query", "Debug", "Выполнить SDQL запрос к игровому миру")
	ADD_VERB("SDQL2 Query", "Debug", "Расширенный язык запросов SDQL2")
	ADD_VERB("View Runtimes", "Debug", "Журнал ошибок времени выполнения (Runtimes)")
	ADD_VERB("Enable Profiler", "Debug", "Включить BYOND профайлер производительности")

	// Server Category
	ADD_VERB_CMD("Server Restart", "Restart", "Server", "Перезагрузить сервер с подтверждением")
	ADD_VERB("Immediate Reboot", "Server", "Мгновенный перезапуск сервера без таймера")
	ADD_VERB_CMD("Server Delay", "Delay", "Server", "Отложить окончание раунда")
	ADD_VERB("Start Now", "Server", "Мгновенно запустить раунд из лобби")
	ADD_VERB("End Now", "Server", "Завершить текущий раунд")
	ADD_VERB("Toggle Ban System", "Server", "Включить / выключить систему банов")
	ADD_VERB("Set Holiday", "Server", "Установить праздничный день в игре")
	ADD_VERB("Capture Map Part", "Server", "Сделать снимок выделенной области карты")

	// Fun Category
	ADD_VERB("Drop Bomb", "Fun", "Сбросить бомбу в указанные координаты")
	ADD_VERB("Cinematic", "Fun", "Воспроизвести кинематографичную заставку")
	ADD_VERB_CMD("Roll Dice", "Roll-Dice", "Fun", "Бросить кубики d20, d6 и др.")
	ADD_VERB("Admin Dress", "Fun", "Одеть моба в выбранный аутфит")
	ADD_VERB_CMD("Make PAI", "Make-pAI", "Fun", "Создать pAI карту из игрока")
	ADD_VERB("Gib Self", "Fun", "Разорвать своего моба на куски")
	ADD_VERB("Toggle Aliens", "Fun", "Включить / выключить ксеноморфов")
	ADD_VERB("Toggle Space Ninja", "Fun", "Включить спавн космического ниндзя")

	// Spawn Category
	ADD_VERB("Spawn Atom", "Spawn", "Спавн любого предмета, моба, турфа или структуры")
	ADD_VERB("Spawn Custom Item", "Spawn", "Спавн кастомных предметов")
	ADD_VERB("Spawn Plant", "Spawn", "Спавн гидропонных растений и семян")
	ADD_VERB("Spawn Fluid", "Spawn", "Создать лужу жидкости")
	ADD_VERB("Virus2 Editor", "Spawn", "Редактор и создание штаммов вирусов")

	// Mapping Category
	ADD_VERB("Map Template Load", "Mapping", "Загрузить шаблон карты в текущий Z-уровень")
	ADD_VERB("Map Template Upload", "Mapping", "Загрузить dmm файл с компьютера на сервер")
	ADD_VERB("Capture Map", "Mapping", "Сохранить карту в файл")

	// Special / Navigation Category
	ADD_VERB_CMD("Jump to Mob", "Jump-To-Mob", "Special", "Телепортироваться к выбранному мобу")
	ADD_VERB_CMD("Jump to Coordinate", "Jump-To-Coord", "Special", "Телепортироваться по X, Y, Z координатам")
	ADD_VERB_CMD("Jump to Turf", "Jump-To-Turf", "Special", "Телепортироваться на указанный турф")
	ADD_VERB_CMD("Get Mob", "Get-Mob", "Special", "Телепортировать моба к себе")
	ADD_VERB_CMD("Get Key", "Get-Key", "Special", "Телепортировать игрока по Ckey к себе")
	ADD_VERB("Play Sound", "Special", "Воспроизвести звуковой файл для всех")
	ADD_VERB("Play Local Sound", "Special", "Воспроизвести звук в радиусе")

	#undef ADD_VERB
	#undef ADD_VERB_CMD

	// Auto-discovery of all other verbs from client and global admin lists
	var/list/candidates = list()
	if(user)
		if(user.client && user.client.verbs)
			candidates |= user.client.verbs
		if(user.verbs)
			candidates |= user.verbs

	candidates |= admin_verbs_default
	candidates |= admin_verbs_admin
	candidates |= admin_verbs_ban
	candidates |= admin_verbs_fun
	candidates |= admin_verbs_server
	candidates |= admin_verbs_debug
	candidates |= admin_verbs_spawn
	candidates |= admin_verbs_sounds
	candidates |= admin_verbs_permissions
	candidates |= admin_verbs_rejuv
	candidates |= admin_verbs_possess
	candidates |= admin_verbs_mod
	candidates |= admin_verbs_mentor

	for(var/v in candidates)
		var/v_text = "[v]"
		var/last_slash = findlasttext(v_text, "/")
		var/raw_name = last_slash ? copytext(v_text, last_slash + 1) : v_text
		var/cmd_name = replacetext(raw_name, "_", "-")

		if(known_by_cmd[lowertext(cmd_name)] || known_by_cmd[lowertext(raw_name)])
			continue

		// Determine category automatically
		var/cat = "Admin"
		if((v in admin_verbs_debug) || (v in admin_verbs_paranoid_debug))
			cat = "Debug"
		else if(v in admin_verbs_fun)
			cat = "Fun"
		else if(v in admin_verbs_server)
			cat = "Server"
		else if(v in admin_verbs_spawn)
			cat = "Spawn"
		else if(v in admin_verbs_sounds)
			cat = "Special"
		else if(v in admin_verbs_possess)
			cat = "Special"

		// Format clean human-readable name
		var/clean_name = raw_name
		if(copytext(clean_name, 1, 11) == "cmd_admin_")
			clean_name = copytext(clean_name, 11)
		else if(copytext(clean_name, 1, 5) == "cmd_")
			clean_name = copytext(clean_name, 5)

		var/list/parts = splittext(clean_name, "_")
		var/list/formatted = list()
		for(var/p in parts)
			if(length(p))
				formatted += capitalize(p)
		var/display_name = jointext(formatted, " ")
		if(!length(display_name))
			display_name = raw_name

		res += list(list(
			"name" = display_name,
			"cmd"  = cmd_name,
			"cat"  = cat,
			"desc" = ""
		))
		known_by_cmd[lowertext(cmd_name)] = TRUE
		known_by_cmd[lowertext(raw_name)] = TRUE

	return res

/client/proc/open_verb_manager()
	set category = "Admin"
	set name = "Verb Manager"
	set desc = "Open the interactive Verb Manager and Master Controller panel (NanoUI)."

	if(holder)
		holder.open_verb_manager()
	else
		to_chat(src, "<span class='warning'>You are not an admin.</span>")
