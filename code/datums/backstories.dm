GLOBAL_LIST_EMPTY(all_backstories)
GLOBAL_LIST_EMPTY(all_backstory_names)

/datum/backstory
	var/name = "None"
	var/category = "General"
	var/desc = "No specific background."
	var/fluff = ""
	var/stats = list()

/datum/backstory/New()
	GLOB.all_backstories |= src
	GLOB.all_backstory_names |= name

	return GLOB.all_backstories

/proc/backstory_initialize()
	GLOB.all_backstories.Cut()
	GLOB.all_backstory_names.Cut()
	for(var/bs in typesof(/datum/backstory))
		. = new bs

/proc/get_all_backstories()
	if(!GLOB.all_backstory_names || !LAZYLEN(GLOB.all_backstory_names))
		backstory_initialize()
	return GLOB.all_backstories

/proc/get_all_backstory_names()
	if(!GLOB.all_backstory_names || !LAZYLEN(GLOB.all_backstory_names))
		backstory_initialize()
	return GLOB.all_backstory_names

/proc/get_backstory(var/naming)
	if(!naming)
		return null
	if(GLOB.all_backstories[naming])
		return GLOB.all_backstories[naming]
	for(var/datum/backstory/bs in GLOB.all_backstories)
		if(bs.name == naming)
			return bs
	return null

/datum/backstory/story
	category = "backstory"

/datum/backstory/story/civilian
	name = "Житель станции"
	desc = " Космос сделал твоё тело более нежным, но научила тебя хорошему."
	fluff = "Обычный житель станций. Каким бы серым человек не был, он живет свою жизнь, полную событий и неудач."
	stats = list(-1, 2, 2, -1)

/datum/backstory/story/worker
	name = "Сотрудник"
	desc = "Годы взяли своё. Ты более опытный в своём ремесле, но в целом, ты больше походишь на говно, чем на человека."
	fluff = "Работа - есть счастье для тех, о ком ты заботишься. Она тебе не нравится, но тебе платят. Ты убиваешься тут в одном и том же ритме, лишь бы твоя семья могла жить спокойно и в достатке."
	stats = list(-1, 2, 2, -2)

/datum/backstory/story/arestant
	name = "Арестант"
	desc = "Тебя запрягают тяжёлой работой. Впрочем и твой ум за все эти годы стал почти как у Землянина."
	fluff = "Жизнь - дерьмо. Власть - ещё большая херь. Ты это знаешь на своей шкуре. Не важно, являешься ли ты мятежником Старого Союза, капером или просто отбросом общества - теперь у тебя новая жизнь. Ты вынужден убивать свой организм ради того, чтобы с тебя сняли пару пожизненных сроков."
	stats = list(2, -1, -2, 1)

/datum/backstory/homesystem
	category = "home_system"

/datum/backstory/homesystem/sol
	name = "Солнечная система"
	desc = "Как правило, выходцы из Сола - потомки тех, кого эвакуировали с планеты уже после начала её разрушения с помощью ОМП."
	fluff = "Колыбель человечества, давно перенаселённая до предела. Несмотря на огромное количество орбитальных станций и новейших сферических станций-городов, здесь всё ещё полно места для самых бедных людей со всего Сектора Крессент."
	stats = list(2, 1, -3, -1)

/datum/backstory/homesystem/zoisha
	name = "Система Зойша"
	desc = "Выходцы из системы Зойша - часто страдают от лёгкой лучевой болезни, из-за постоянной работы с Элериумом. И лишь благодаря постоянной угрозе с этим ценным минералом, многие семьи могут позволить достойное обучение своим детям"
	fluff = "Знаменитая своими максимально благоприятными для терраформинга планетами.  Не без причины стала самым продвинутым участком всего человечества, вскоре став центром всей Лиги. Благодаря усилиям государств и корпораций это место ближе всех к становлению настоящим раем."
	stats = list(1, 2, 3, -3)

/datum/backstory/homesystem/irtema
	name = "Система Иртэма"
	desc = "Обитатели планеты Исфет известны своими могучими телами - тяжёлая гравитация способствует набору мышечной массы. Впрочем, это же заставляет весь Сектор Крессент считать их неуклюжими."
	fluff = "Имея не лучшую репутацию из-за беженцев из Красного Союза, Иртэма остаëтся главнейшей системой по исследованию псионического потенциала человечества, как и самой благоприятной и гостеприимной ко всем отщепенцам. Из-за наличия лишь одной пригодной для жизни планеты, ТНС отстроила грандиозную станцию, где семьи из Лиги и Корпорации могут жить в достатке и радости."
	stats = list(2, -4, -1, 2)

/datum/backstory/homesystem/shaos
	name = "Система Шаос"
	desc = "Безумцы, что смеют продолжать жить на Шаос-Прайме и станциях вокруг, известны своими странными, длинными и ловкими конечностями."
	fluff = "Система Шаос стала самым первым сырьевым придатком Красного Союза, а сразу после и свалкой Мегакорпораций. Несмотря на свою историческую ценность как первой колонизированной, эта система повторила судьбу Солнечной."
	stats = list(-2, 4, -2, 1)

/datum/backstory/homesystem/sectors
	name = "Малые сектора"
	desc = "Малоизвестные люди, которые не похожи друг на друга."
	fluff = "Сектор Крессент cлишком обширен, от чего довольно сложно знать о каждой мелкой станции или астероидной базе"
