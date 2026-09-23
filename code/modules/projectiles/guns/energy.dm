/obj/item/weapon/gun/energy
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon_state = "energy"
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_sound_text = "laser blast"

	var/obj/item/weapon/cell/power_supply // What type of power cell this starts with. Uses accepts_cell_type or variable cell if unset.
	var/charge_cost = 20           // How much energy is needed to fire.
	var/max_shots = 10             // Determines the capacity of the weapon's power cell. Setting power_supply or accepts_cell_type will override this value.
	var/modifystate                // Changes the icon_state used for the charge overlay.
	var/charge_meter = 1           // If set, the icon state will be chosen based on the current charge
	var/indicator_color            // Color used for overlay based charge meters
	var/self_recharge = 0          // If set, the weapon will recharge itself
	var/use_external_power = 0     // If set, the weapon will look for an external power source to draw from, otherwise it recharges magically
	var/recharge_time = 4          // How many ticks between recharges.
	var/charge_tick = 0            // Current charge tick tracker.
	var/accepts_cell_type          // Specifies a cell type that can be loaded into this weapon.
	// Which projectile type to create when firing.
	var/projectile_type = /obj/item/projectile/beam/practice
	//self-recharging
	var/icon_rounder = 25
	combustion = 1
	deaf_ability = 0

	z_flags = ZMM_MANGLE_PLANES

/obj/item/weapon/gun/energy/switch_firemodes()
	. = ..()
	if(.)
		update_icon()

/obj/item/weapon/gun/energy/emp_act(severity)
	..()
	update_icon()

/obj/item/weapon/gun/energy/Initialize()

	if(ispath(power_supply))
		power_supply = new power_supply(src)
	else if(accepts_cell_type)
		power_supply = new accepts_cell_type(src)
	else
		power_supply = new /obj/item/weapon/cell/device/variable(src, max_shots*charge_cost)

	. = ..()

	if(self_recharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/weapon/gun/energy/Destroy()
	if(self_recharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/Process()
	if(self_recharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(!power_supply || power_supply.charge >= power_supply.maxcharge)
			return 0 // check if we actually need to recharge

		if(use_external_power)
			var/obj/item/weapon/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost)) //Take power from the borg...
				return 0

		power_supply.give(charge_cost) //... to recharge the shot
		update_icon()
	return 1

/obj/item/weapon/gun/energy/consume_next_projectile()
	if(!power_supply)
		return null
	if(!ispath(projectile_type))
		return null
	if(!power_supply.checked_use(charge_cost))
		return null
	return new projectile_type(src)

/obj/item/weapon/gun/energy/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/weapon/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

/obj/item/weapon/gun/energy/examine(mob/user)
	. = ..(user)
	var/shots_remaining = round(power_supply.charge / charge_cost)
	to_chat(user, "Has [shots_remaining] shot\s remaining.")
	return

/obj/item/weapon/gun/energy/update_icon()
	..()
	if(charge_meter)
		var/ratio = power_supply.percent()

		//make sure that rounding down will not give us the empty state even if we have charge for a shot left.
		if(power_supply.charge < charge_cost)
			ratio = 0
		else
			ratio = max(round(ratio, icon_rounder), icon_rounder)

		if(modifystate)
			icon_state = "[modifystate][ratio]"
		else
			icon_state = "[initial(icon_state)][ratio]"

//For removable cells.
/obj/item/weapon/gun/energy/MouseDrop(mob/user, var/obj/over_object)
	if(isnull(power_supply))
		return ..()
	if (!over_object || !(ishuman(usr) || issmall(usr)))
		return
	if (!(src.loc == usr))
		return

	switch(over_object.name)
		if("r_hand")
			user.put_in_hands(power_supply)
			power_supply = null
			user.visible_message(SPAN_NOTICE("\The [user] unloads \the [src]."))
			playsound(src,'sound/weapons/guns/interaction/smg_magout.ogg' , 50)
			update_icon()
		if("l_hand")
			user.put_in_hands(power_supply)
			power_supply = null
			user.visible_message(SPAN_NOTICE("\The [user] unloads \the [src]."))
			playsound(src,'sound/weapons/guns/interaction/smg_magout.ogg' , 50)
			update_icon()

/obj/item/weapon/gun/energy/attackby(var/obj/item/A, mob/user)

	if(istype(A, /obj/item/weapon/cell))

		if(isnull(accepts_cell_type))
			to_chat(user, SPAN_WARNING("\The [src] cannot accept a cell."))
			return TRUE

		if(!istype(A, accepts_cell_type))
			var/obj/cell_dummy = accepts_cell_type
			to_chat(user, SPAN_WARNING("\The [src]'s cell bracket can only accept \a [initial(cell_dummy.name)]."))
			return TRUE

		if(istype(power_supply) )
			to_chat(user, SPAN_NOTICE("\The [src] already has \a [power_supply] loaded."))
			return TRUE

		if(!do_after(user, 5, A))
			return TRUE

		if(user.unEquip(A, src))
			power_supply = A
			user.visible_message(SPAN_WARNING("\The [user] loads \the [A] into \the [src]!"))
			playsound(src, 'sound/weapons/guns/energy_magin.ogg', 80)
			update_icon()
		return TRUE

	return ..()