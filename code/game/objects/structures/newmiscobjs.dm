/obj/structure/body1
	name = "rotting body"
	desc = "Rotting and festering. Seems like it was here for a while."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "dead1"
	layer = ABOVE_HUMAN_LAYER
	density = 0
	anchored = 1
	w_class = ITEM_SIZE_NORMAL

/obj/structure/body1/New()
	..()

/obj/structure/body1/attackby(obj/item/I, mob/user)
	to_chat(user, "<span class='warning'>\The [src] doesn't seem to be very alive!</span>")
	return

/obj/structure/body2
	name = "rotting body"
	desc = "Rotting and festering. Seems like it was here for a while."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "dead2"
	layer = ABOVE_HUMAN_LAYER
	density = 0
	anchored = 1
	w_class = ITEM_SIZE_NORMAL

/obj/structure/body2/New()
	..()

/obj/structure/body2/attackby(obj/item/I, mob/user)
	to_chat(user, "<span class='warning'>\The [src] doesn't seem to be very alive!</span>")
	return

/obj/structure/body3
	name = "rotting body on a spike"
	desc = "Rotting and festering. Seems like it was here for a while. Is impaled on a spike."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "dead3"
	layer = ABOVE_HUMAN_LAYER
	density = 0
	anchored = 1
	w_class = ITEM_SIZE_NORMAL

/obj/structure/body3/New()
	..()

/obj/structure/body3/attackby(obj/item/I, mob/user)
	to_chat(user, "<span class='warning'>\The [src] doesn't seem to be very alive!</span>")
	return

/obj/structure/woodentv
	name = "wooden tv"
	desc = "An old, wooden TV. Doesn't seem to show anything of value."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "wooden_tv_unpowered"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/woodentv/on
	icon_state = "wooden_tv"
	layer = ABOVE_HUMAN_LAYER
	anchored = 1

/obj/structure/woodentv/attack_hand(mob/user)
	playsound(get_turf(loc), "button2", 15, 1, -5)
	toggle()
	..()

/obj/structure/woodentv/proc/toggle()
	if(attack_hand())
		icon_state = "wooden_tv"
		layer = ABOVE_WINDOW_LAYER
	else
		icon_state = "wooden_tv_unpowered"
		layer = ABOVE_WINDOW_LAYER

/obj/structure/microscope
	name = "microscope"
	desc = "A microscope. It's broken."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "microscope1"
	layer = ABOVE_WINDOW_LAYER
	density = 1

/obj/structure/fishwall
	name = "a fish trophy"
	desc = "A fish trophy on the wall. Doesn't seem to play anything anymore...unless?"
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "fish"
	pixel_y = 32
	layer = ABOVE_WINDOW_LAYER
	density = 0

/obj/structure/hospitaltech1
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a3"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hospitaltech2
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a5"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hospitaltech3
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a9"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/merzikas
	name = "merzikas"
	desc = "A lost soul."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "merzikas"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/merzikas2
	name = "merzikas"
	desc = "A lost soul."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "merzikas2"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/hellmushroom
	name = "flesh mushroom"
	desc = "A big mushroom with veins with blood running through."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellmushroom"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hellskull
	name = "skull"
	desc = "A lost soul."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellskull"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/hellskulls
	name = "skull"
	desc = "A lost soul."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellskulls"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/bloodveins
	name = "veins"
	desc = "Looks like veins with blood running through them."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "bloodveins"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/bloodflower
	name = "blood flowers"
	desc = "Looks like flowers made of flesh."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "bloodflower"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/gore
	name = "pile of gore"
	desc = "Looks like a pile of flesh and blood."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "gore"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/statue
	name = "statue"
	desc = "Looks like a columm made of flesh and bone."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "statue"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/merzikas3
	name = "Merzikas"
	desc = "A lost soul."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "merzikas3"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hellglos
	name = "flesh glos"
	desc = "A greenish light source."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellglos"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1
	set_light(l_range = 5, l_power = 2, l_color = "#33ff9c")

/obj/structure/hellplant2
	name = "flesh plant"
	desc = "A plant of sorts. Looks alive."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellplant2"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/bloodworms
	name = "blood worms"
	desc = "A bunch of worms."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "bloodworms"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/hellcage
	name = "flesh cage"
	desc = "A cage of sorts to torture the damned."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellcage"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/bloodsucker
	name = "blood sucker"
	desc = "What is that thing??"
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "bloodsucker"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/hellsign
	name = "sign"
	desc = "Eternal Suffering."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "hellsign"
	layer = ABOVE_WINDOW_LAYER
	density = 0
	anchored = 1

/obj/structure/hellcross
	name = "rune cross"
	desc = "A upside down cross with weird blood runes on it. Very strange."
	icon = 'icons/obj/miscobjsbig.dmi'
	icon_state = "hellcross"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hellheart
	name = "Hells heart"
	desc = "A huge floating big beating heart of flesh??"
	icon = 'icons/obj/miscobjsbig.dmi'
	icon_state = "hellsheart"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hospitaltech4
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a10"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hospitaltech5
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a11"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/hospitaltech6
	name = "some hospital device"
	desc = "A weird hospital device. Doesn't do anything except...work on something."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a13"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/woodenclock
	name = "old wooden clock"
	desc = "An old, wooden clock. Tick tack."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "pclock"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1

/obj/structure/woodenclock/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/woodenclock/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/woodenclock/Process()
	playsound(src, 'sound/machines/clock_ticking.ogg', 20, 0)

/obj/structure/nuclearwaste
	name = "big nuclear waste canister"
	desc = "A big nuclear waste canister. Better stay away from this..."
	icon = 'icons/obj/miscobjs.dmi'
	icon_state = "a8"
	layer = ABOVE_WINDOW_LAYER
	density = 1
	anchored = 1
	var/radioactivity = 1

/obj/structure/nuclearwaste/New()
	..()
	if(istype(loc, /turf))
		SSradiation.radiate(src, max(1,ceil(radioactivity/30))) //I'm not sure how OP this is...

/obj/structure/vent_gas
	desc = "A large ventilation panel with an ungodly stench coming out of it."
	name = "vent"
	icon = 'icons/obj/structures.dmi'
	icon_state = "obj37"
	density = 0
	anchored = 1
	layer = ABOVE_WINDOW_LAYER

/obj/structure/vent_gas/New()
	..()
	processing()

/obj/structure/vent_gas/proc/processing()
	while(TRUE)
		sleep(20)
		spawn(45)
			playsound(src.loc, 'sound/machines/loop_vent2.ogg', 10, 0, 3)
		for(var/i = 0; 6 > i; i++)
			var/obj/effect/gas_particle/O = new(src.loc)
			animate(O, pixel_y = rand(50, 98), time=rand(14,20))
			sleep(5)
			spawn(20)
				animate(O, alpha = 0, time = 20)
				spawn(20)
					qdel(O)

/obj/effect/gas_particle
	name = "gas particles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke2"
	opacity = 0
	anchored = 1
	layer = ABOVE_PROJECTILE_LAYER
	plane = 2
	alpha = 130
	mouse_opacity = 0

/obj/effect/gas_particle/New()
	..()
	src.pixel_x = rand(-5,5)
	src.pixel_y = rand(-5, 2)
	src.icon = turn(src.icon,rand(0,90))

/obj/structure/vent_gas_deactivated
	desc = "A large ventilation panel which used to have an ungodly stench come out of it."
	name = "vent"
	icon = 'icons/obj/structures.dmi'
	icon_state = "obj37"
	density = 0
	anchored = 1
	layer = ABOVE_WINDOW_LAYER
