/obj/machinery/food_replicator
	name = "replicator"
	desc = "A large steel machine, which works as a replicator for cheap 'food'. May induce vomiting."
	icon = 'icons/obj/machines/replicator.dmi'
	icon_state = "replicator"
	density = 1
	anchored = 1
	idle_power_usage = 40
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/biomass = 100
	var/biomass_max = 100
	var/biomass_per = 10
	var/deconstruct_eff = 0.5
	var/list/queued_dishes = list()
	var/make_time = 0
	var/start_making = 0
	var/list/menu = list("батончик" = /obj/item/weapon/reagent_containers/food/snacks/tofu,
					"индейка-содержимое" = /obj/item/weapon/reagent_containers/food/snacks/tofurkey,
					"вафле-содержащее" = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians,
					"картошка" = /obj/item/weapon/reagent_containers/food/snacks/fries,
					"пищевая паста" = /obj/item/weapon/reagent_containers/food/snacks/soydope,
					"пуддинговая масса" = /obj/item/weapon/reagent_containers/food/snacks/ricepudding)

/obj/machinery/food_replicator/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/replicator(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src) //used to hold the biomass
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src) //used to cook the food
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src) //used to deconstruct the stuff

	RefreshParts()

/obj/machinery/food_replicator/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = O
		user.drop_item(O)
		for(var/datum/reagent/nutriment/N in S.reagents.reagent_list)
			biomass = clamp(biomass + round(N.volume*deconstruct_eff),1,biomass_max)
		qdel(O)
	else if(istype(O, /obj/item/weapon/storage/plants))
		if(!O.contents || !O.contents.len)
			return
		to_chat(user, "You empty \the [O] into \the [src]")
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			var/obj/item/weapon/storage/S = O
			S.remove_from_storage(G, null)
			for(var/datum/reagent/nutriment/N in G.reagents.reagent_list)
				biomass = clamp(biomass + round(N.volume*deconstruct_eff),1,biomass_max)
			qdel(G)

	if(default_deconstruction_screwdriver(user, O))
		return
	else if(default_deconstruction_crowbar(user, O))
		return
	else if(default_part_replacement(user, O))
		return
	else
		..()
	return

/obj/machinery/food_replicator/update_icon()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_d"
	else if( !(stat & NOPOWER) )
		icon_state = initial(icon_state)
	else
		src.icon_state = "[initial(icon_state)]_d"

/obj/machinery/food_replicator/hear_talk(mob/M as mob, text, verb, datum/language/speaking)
	if(!speaking || speaking.machine_understands)
		spawn(20)
			var/true_text = lowertext(html_decode(text))
			for(var/menu_item in menu)
				if(findtext(true_text, menu_item))
					queue_dish(menu_item)
			if(findtext(true_text, "Статус"))
				state_status()
			else if(findtext(true_text, "Меню"))
				state_menu()
	..()

/obj/machinery/food_replicator/proc/state_status()
	var/message_bio = "boop beep"
	if(biomass == 0)
		message_bio = "Биомасса отсутствует!"
	else if(biomass <= biomass_max/4)
		message_bio = "Биомасса почти исчерпана."
	else if(biomass <= biomass_max/2)
		message_bio = "Биомасса наполовину пуста."
	else if(biomass != biomass_max)
		message_bio = "Биомасса почти полна!"
	else
		message_bio = "Биомасса переполнена!"
	src.audible_message("<b>\The [src]</b> states, \"[message_bio]\"")

/obj/machinery/food_replicator/proc/state_menu()
	src.audible_message("<b>\The [src]</b> states, \"Доступны следующие блюда: [english_list(menu)].\"")

/obj/machinery/food_replicator/proc/dispense_food(var/text)
	var/type = menu[text]
	if(!type)
		src.audible_message("<b>\The [src]</b> states, \"Ошибка! Не найден рецепт продукта.\"")
		return 0

	if(biomass < biomass_per)
		src.audible_message("<b>\The [src]</b> states, \"Ошибка! Недостаточно биомассы.\"")
		queued_dishes.Cut()
		return 0
	biomass -= biomass_per
	src.audible_message("<b>\The [src]</b> states, \"Ваш заказ: [text], готов!\"")
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.icon_state = "[initial(icon_state)]_p"
	var/atom/A = new type(src.loc)
	A.SetName(text)
	A.desc = "Looks... actually pretty good."
	use_power_oneoff(75000)
	update_icon()
	return 1

/obj/machinery/food_replicator/RefreshParts()
	deconstruct_eff = 0
	biomass_max = 0
	biomass_per = 20
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
			biomass_max += 100 * P.rating
		if(istype(P, /obj/item/weapon/stock_parts/manipulator))
			biomass_per = max(1, biomass_per - 5 * P.rating)
		if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
			deconstruct_eff += 0.5 * P.rating
	biomass = min(biomass,biomass_max)

/obj/machinery/food_replicator/proc/queue_dish(var/text)
	if(!(text in menu))
		return

	if(!queued_dishes)
		queued_dishes = list()

	queued_dishes += text
	if(world.time > make_time)
		start_making = 1

/obj/machinery/food_replicator/Process()
	if(queued_dishes && queued_dishes.len)
		if(start_making) //want to do this first so that the first dish won't instantly come out
			src.audible_message("<b>\The [src]</b> rumbles and vibrates.")
			playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
			make_time = world.time + rand(100, 300)
			start_making = 0
		if(world.time > make_time)
			dispense_food(queued_dishes[1])
			if(queued_dishes && queued_dishes.len) //more to come
				queued_dishes -= queued_dishes[1]
				start_making = 1
	..()

/obj/machinery/food_replicator/examine(mob/user)
	. = ..(user)
	if(panel_open)
		to_chat(user, "The maintenance hatch is open.")

/obj/structure/reagent_dispensers/biomasstank
	name = "biomass tank"
	desc = "A metal tank."
	anchored = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "10;25;50;100"
	initial_capacity = 100
	initial_reagent_types = list(/datum/reagent/nutriment = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/reagent_dispensers/metalwatertank
	name = "metal watertank"
	desc = "A tank containing water."
	anchored = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "10;25;50;100"
	initial_capacity = 1000
	initial_reagent_types = list(/datum/reagent/water = 1)
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/machinery/gibber/biomassmaker
	name = "nutrient liquefier"
	desc = "a machine that liquefies all that goes into"
	var/obj/structure/reagent_dispensers/biomasstank/tank

/obj/machinery/gibber/biomassmaker/Initialize()
	. = ..()
	tank = locate(/obj/structure/reagent_dispensers/biomasstank) in oview(1,loc)

/obj/machinery/gibber/biomassmaker/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return

	use_power_oneoff(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")
	src.operating = 1
	update_icon()

	var/nutrients = 0

	// Some mobs have specific meat item types.
	if(istype(src.occupant,/mob/living/simple_animal))
		var/mob/living/simple_animal/critter = src.occupant
		if(critter.meat_amount)
			nutrients += critter.meat_amount*(rand(3,7))

	else if(istype(src.occupant,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = occupant
		for (var/obj/item/organ/external/O in H.organs)
			nutrients += rand(5, 20)
		for (var/obj/item/organ/internal/I in H.organs)
			nutrients += rand(3, 10)

	// Small mobs don't give as much nutrition.
	if(issmall(src.occupant))
		nutrients *= 0.5

	admin_attack_log(user, occupant, "Gibbed the victim", "Was gibbed", "gibbed")

	spawn(gib_time)

		src.occupant.reagents.trans_to_obj(tank)
		src.occupant.death(1)
		tank.reagents.add_reagent(/datum/reagent/nutriment, nutrients)
		qdel(src.occupant)

		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0
		update_icon()