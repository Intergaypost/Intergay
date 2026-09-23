/turf/simulated/floor/attackby(var/obj/item/C, var/mob/user)

	if(!C || !user)
		return 0

	if(isCoil(C) || (flooring && istype(C, /obj/item/stack/rods)))
		return ..(C, user)

	if(!(isScrewdriver(C) && flooring && (flooring.flags & TURF_REMOVE_SCREWDRIVER)))
		return

	if(flooring)
		if(isCrowbar(C))
			if(broken || burnt)
				to_chat(user, "<span class='notice'>You remove the broken [flooring.descriptor].</span>")
				make_plating()
			else if(flooring.flags & TURF_IS_FRAGILE)
				to_chat(user, "<span class='danger'>You forcefully pry off the [flooring.descriptor], destroying them in the process.</span>")
				make_plating()
			else if(flooring.flags & TURF_REMOVE_CROWBAR)
				to_chat(user, "<span class='notice'>You lever off the [flooring.descriptor].</span>")
				make_plating(1)
			else
				return
			playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
			return
		else if(isScrewdriver(C) && (flooring.flags & TURF_REMOVE_SCREWDRIVER))
			if(broken || burnt)
				return
			to_chat(user, "<span class='notice'>You unscrew and remove the [flooring.descriptor].</span>")
			make_plating(1)
			playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
			return
		else if(isWrench(C) && (flooring.flags & TURF_REMOVE_WRENCH))
			to_chat(user, "<span class='notice'>You unwrench and remove the [flooring.descriptor].</span>")
			make_plating(1)
			playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
			return
		else if(istype(C, /obj/item/weapon/shovel) && (flooring.flags & TURF_REMOVE_SHOVEL))
			to_chat(user, "<span class='notice'>You shovel off the [flooring.descriptor].</span>")
			make_plating(1)
			playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
			return
		else if(isCoil(C))
			to_chat(user, "<span class='warning'>You must remove the [flooring.descriptor] first.</span>")
			return
	else

		if(istype(C, /obj/item/stack))
			if(broken || burnt)
				to_chat(user, "<span class='warning'>This section is too damaged to support anything. Use a welder to fix the damage.</span>")
				return
			//first check, catwalk? Else let flooring do its thing
			if(locate(/obj/structure/catwalk, src))
				return
			if (istype(C, /obj/item/stack/rods))
				var/obj/item/stack/rods/R = C
				if (R.use(2))
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					new /obj/structure/catwalk(src)
				return
			var/obj/item/stack/S = C
			var/decl/flooring/use_flooring
			for(var/flooring_type in flooring_types)
				var/decl/flooring/F = flooring_types[flooring_type]
				if(!F.build_type)
					continue
				if(ispath(S.type, F.build_type) || ispath(S.build_type, F.build_type))
					use_flooring = F
					break
			if(!use_flooring)
				return
			// Do we have enough?
			if(use_flooring.build_cost && S.get_amount() < use_flooring.build_cost)
				to_chat(user, "<span class='warning'>You require at least [use_flooring.build_cost] [S.name] to complete the [use_flooring.descriptor].</span>")
				return
			// Stay still and focus...
			if(use_flooring.build_time && !do_after(user, use_flooring.build_time, src))
				return
			if(flooring || !S || !user || !use_flooring)
				return
			if(S.use(use_flooring.build_cost))
				set_flooring(use_flooring)
				playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
				return
		// Repairs and Deconstruction.
		else if(isCrowbar(C))
			if(broken || burnt)
				playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
				visible_message("<span class='notice'>[user] has begun prying off the damaged plating.</span>")
				var/turf/T = GetBelow(src)
				if(T)
					T.visible_message("<span class='warning'>The ceiling above looks as if it's being pried off.</span>")
				if(do_after(user, 10 SECONDS))
					visible_message("<span class='warning'>[user] has pried off the damaged plating.</span>")
					new /obj/item/stack/tile/floor(src)
					src.ReplaceWithLattice()
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					if(T)
						T.visible_message("<span class='danger'>The ceiling above has been pried off!</span>")
			else
				return
			return
		else if(isWelder(C))
			var/obj/item/weapon/weldingtool/welder = C
			if(welder.isOn() && (is_plating()))
				if(broken || burnt)
					if(welder.isOn())
						to_chat(user, "<span class='notice'>You fix some dents on the broken plating.</span>")
						playsound(src, 'sound/items/Welder.ogg', 80, 1)
						icon_state = "plating"
						burnt = null
						broken = null
					else
						to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
					return
				else
					if(welder.isOn())
						playsound(src, 'sound/items/Welder.ogg', 80, 1)
						visible_message("<span class='notice'>[user] has started melting the plating's reinforcements!</span>")
						if(do_after(user, 5 SECONDS) && welder.isOn())
							visible_message("<span class='warning'>[user] has melted the plating's reinforcements! It should be possible to pry it off.</span>")
							playsound(src, 'sound/items/Welder.ogg', 80, 1)
							burnt = 1
							remove_decals()
							update_icon()
					else
						to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
					return


		if(istype(C, /obj/item/grab) && get_dist(src,user)<2)
			var/obj/item/grab/G = C
			if(G.assailant.zone_sel.selecting == "head" && G.affecting.lying)
				if(ishuman(G.affecting))
/*
					G.affecting.attack_log += text("\[[time_stamp()]\] <span class='warning'>Has been smashed on the floor by [G.assailant.name] ([G.assailant.ckey])</font>")
					G.assailant.attack_log += text("\[[time_stamp()]\] <span class='danger'>Smashed [G.affecting.name] ([G.affecting.ckey]) on the floor.</font>")

					//log_admin("ATTACK: [G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.", 2)
					message_admins("ATTACK: [G.assailant] ([G.assailant.ckey])(<a href='byond://?_src_=holder;adminplayerobservejump=\ref[G]'>JMP</A>) smashed [G.affecting] ([G.affecting.ckey]) on the floor.", 2)
					log_attack("[G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.")
*/

					var/mob/living/carbon/human/H = G.affecting
					var/obj/item/organ/external/affecting = H.get_organ("head")
					if(prob(25))
						affecting.take_external_damage(rand(25,35), 0)
						H.Weaken(2)
						if(prob(20)) // One chance in 20 to DENT THE TABLE
							affecting.take_external_damage(rand(8,15), 0) //Extra damage
							H.apply_effect(5, PARALYZE)
							visible_message("<span class='danger'><b>[H]</b>< has been knocked unconscious!</span>")
							H.ear_damage += rand(0, 3)
							H.ear_deaf = max(H.ear_deaf,6)
							G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] with enough force to further deform \the [src]!\nYou wish you could unhear that sound.",\
							"\red You smash \the [H]'s head on \the [src] with enough force to leave another dent!\n[prob(50)?"That was a satisfying noise." : "That sound will haunt your nightmares"]",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal and the squeal of said metal deforming.")
						else if(prob(50))
							G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.get_visible_gender() == MALE ? "his" : H.get_visible_gender() == FEMALE ? "her" : "their"] bone and cartilage making a loud crunch!",\
							"\red You smash \the [H]'s head on \the [src], [H.get_visible_gender() == MALE ? "his" : H.get_visible_gender() == FEMALE ? "her" : "their"] bone and cartilage making a loud crunch!",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal, the noise echoing through the room.")
						else
							G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.get_visible_gender() == MALE ? "his" : H.get_visible_gender() == FEMALE ? "her" : "their"] nose smashed and face bloodied!",\
							"\red You smash \the [H]'s head on \the [src], [H.get_visible_gender() == MALE ? "his" : H.get_visible_gender() == FEMALE ? "her" : "their"] nose smashed and face bloodied!",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal and the gurgling gasp of someone who is trying to breathe through their own blood.")
					else
						affecting.take_external_damage(rand(5,10), 0)
						G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src]!",\
						"\red You smash \the [H]'s head on \the [src]!",\
						"\red You hear the nauseating crunch of bone and gristle on solid metal.")
					add_blood(G.affecting, 1) //Forced
					H.UpdateDamageIcon()
					H.updatehealth()
					var/mob/living/carbon/human/AS = G.assailant
					AS.adjustStaminaLoss(rand(6,15))
					playsound(H.loc, pick('sound/effects/gore/smash1.ogg','sound/effects/gore/smash2.ogg','sound/effects/gore/smash3.ogg'), 50, 1, -3)
					user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
					qdel(G)

	return ..()

/turf/simulated/floor/acid_melt()
	. = FALSE
	var/turf/T = GetBelow(src)

	if(flooring)
		visible_message("<span class='alium'>The acid dissolves the [flooring.descriptor]!</span>")
		make_plating()

	else if(is_plating() && !(broken || burnt))
		playsound(src, 'sound/items/Welder.ogg', 80, 1)
		visible_message("<span class='alium'>The acid has started melting \the [name]'s reinforcements!</span>")
		if(T)
			T.audible_message("<span class='warning'>A strange sizzling noise eminates from the ceiling.</span>")
		burnt = 1
		remove_decals()
		update_icon()

	else if(broken || burnt)
		if(acid_melted == 0)
			visible_message("<span class='alium'>The acid has melted the plating's reinforcements! It's about to break through!.</span>")
			playsound(src, 'sound/items/Welder.ogg', 80, 1)

			if(T)
				T.visible_message("<span class='warning'>A strange substance drips from the ceiling, dropping below with a sizzle.</span>")
			acid_melted++
		else
			visible_message("<span class='danger'>The acid melts the plating away into nothing!</span>")
			new /obj/item/stack/tile/floor(src)
			src.ReplaceWithLattice()
			playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
			if(T)
				T.visible_message("<span class='danger'>The ceiling above melts away!</span>")
			. = TRUE
			qdel(src)
	else
		return TRUE

/turf/simulated/floor/can_build_cable(var/mob/user)
	if(!is_plating() || flooring)
		to_chat(user, "<span class='warning'>Removing the tiling first.</span>")
		return 0
	if(broken || burnt)
		to_chat(user, "<span class='warning'>This section is too damaged to support anything. Use a welder to fix the damage.</span>")
		return 0
	return 1
