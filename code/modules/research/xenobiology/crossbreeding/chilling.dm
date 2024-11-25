/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/chilling
	name = "chilling extract"
	desc = ""
	effect = "chilling"
	icon_state = "chilling"

/obj/item/slimecross/chilling/Initialize()
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, span_warning("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, span_notice("I squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	do_effect(user)

/obj/item/slimecross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/chilling/grey
	colour = "grey"
	effect_desc = ""

/obj/item/slimecross/chilling/grey/do_effect(mob/user)
	user.visible_message(span_notice("[src] produces a few small, grey cubes"))
	for(var/i in 1 to 3)
		new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/slimecross/chilling/orange
	colour = "orange"
	effect_desc = ""

/obj/item/slimecross/chilling/orange/do_effect(mob/user)
	user.visible_message(span_danger("[src] shatters, and lets out a jet of heat!"))
	for(var/turf/T in orange(get_turf(user),2))
		if(get_dist(get_turf(user), T) > 1)
			new /obj/effect/hotspot(T)
	..()

/obj/item/slimecross/chilling/purple
	colour = "purple"
	effect_desc = ""

/obj/item/slimecross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, span_warning("[src] can't affect such a large area."))
		return
	user.visible_message(span_notice("[src] shatters, and a healing aura fills the room briefly."))
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)
	..()

/obj/item/slimecross/chilling/blue
	colour = "blue"
	effect_desc = ""

/obj/item/slimecross/chilling/blue/do_effect(mob/user)
	user.visible_message(span_notice("[src] cracks, and spills out a liquid goo, which reforms into a mask!"))
	new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/slimecross/chilling/metal
	colour = "metal"
	effect_desc = ""

/obj/item/slimecross/chilling/metal/do_effect(mob/user)
	user.visible_message(span_danger("[src] melts like quicksilver, and surrounds [user] in a wall!"))
	for(var/turf/T in orange(get_turf(user),1))
		if(get_dist(get_turf(user), T) > 0)
			new /obj/effect/forcefield/slimewall(T)
	..()

/obj/item/slimecross/chilling/darkpurple
	colour = "dark purple"
	effect_desc = ""

/obj/item/slimecross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, span_warning("[src] can't affect such a large area."))
		return
	var/filtered = FALSE
	for(var/turf/open/T in A)
		var/datum/gas_mixture/G = T.air
		if(istype(G))
			G.assert_gas(/datum/gas/plasma)
			G.gases[/datum/gas/plasma][MOLES] = 0
			filtered = TRUE
			G.garbage_collect()
			T.air_update_turf()
	if(filtered)
		user.visible_message(span_notice("Cracks spread throughout [src], and some air is sucked in!"))
	else
		user.visible_message(span_notice("[src] cracks, but nothing happens."))
	..()

/obj/item/slimecross/chilling/darkblue
	colour = "dark blue"
	effect_desc = ""

/obj/item/slimecross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(span_notice("[src] freezes over [user]'s entire body!"))
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/frozenstasis)
	..()

/obj/item/slimecross/chilling/silver
	colour = "silver"
	effect_desc = ""

/obj/item/slimecross/chilling/silver/do_effect(mob/user)
	user.visible_message(span_notice("[src] crumbles into icy powder, leaving behind several emergency food supplies!"))
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(user))
	..()

/obj/item/slimecross/chilling/bluespace
	colour = "bluespace"
	effect_desc = ""
	var/list/allies = list()
	var/active = FALSE

/obj/item/slimecross/chilling/bluespace/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target) || active)
		return
	if(target in allies)
		allies -= target
		to_chat(user, span_notice("I unlink [src] with [target]."))
	else
		allies |= target
		to_chat(user, span_notice("I link [src] with [target]."))
	return

/obj/item/slimecross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, span_warning("[src] is not linked to anyone!"))
		return
	to_chat(user, span_notice("I feel [src] pulse as it begins charging bluespace energies..."))
	active = TRUE
	for(var/mob/living/M in allies)
		var/datum/status_effect/slimerecall/S = M.apply_status_effect(/datum/status_effect/slimerecall)
		S.target = user
	if(do_after(user, 100, target=src))
		to_chat(user, span_notice("[src] shatters as it tears a hole in reality, snatching the linked individuals from the void!"))
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			M.remove_status_effect(S)
	else
		to_chat(user, span_warning("[src] falls dark, dissolving into nothing as the energies fade away."))
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			if(istype(S))
				S.interrupted = TRUE
				M.remove_status_effect(S)
	..()

/obj/item/slimecross/chilling/sepia
	colour = "sepia"
	effect_desc = ""
	var/list/allies = list()

/obj/item/slimecross/chilling/sepia/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(target in allies)
		allies -= target
		to_chat(user, span_notice("I unlink [src] with [target]."))
	else
		allies |= target
		to_chat(user, span_notice("I link [src] with [target]."))
	return

/obj/item/slimecross/chilling/sepia/do_effect(mob/user)
	user.visible_message(span_warning("[src] shatters, freezing time itself!"))
	allies -= user //support class
	new /obj/effect/timestop(get_turf(user), 2, 300, allies)
	..()

/obj/item/slimecross/chilling/cerulean
	colour = "cerulean"
	effect_desc = ""

/obj/item/slimecross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message(span_warning("[src] creaks and shifts into a clone of [user]!"))
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/slime_clone)
	..()

/obj/item/slimecross/chilling/pyrite
	colour = "pyrite"
	effect_desc = ""

/obj/item/slimecross/chilling/pyrite/do_effect(mob/user)
	user.visible_message(span_notice("[src] crystallizes into a pair of spectacles!"))
	new /obj/item/clothing/glasses/prism_glasses(get_turf(user))
	..()

/obj/item/slimecross/chilling/red
	colour = "red"
	effect_desc = ""

/obj/item/slimecross/chilling/red/do_effect(mob/user)
	var/slimesfound = FALSE
	for(var/mob/living/simple_animal/slime/S in view(get_turf(user), 7))
		slimesfound = TRUE
		S.docile = TRUE
	if(slimesfound)
		user.visible_message(span_notice("[src] lets out a peaceful ring as it shatters, and nearby slimes seem calm."))
	else
		user.visible_message(span_notice("[src] lets out a peaceful ring as it shatters, but nothing happens..."))
	..()

/obj/item/slimecross/chilling/green
	colour = "green"
	effect_desc = ""

/obj/item/slimecross/chilling/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/gun/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message(span_warning("[src] flash-freezes [user]'s arm, cracking the flesh horribly!"))
	else
		user.visible_message(span_danger("[src] chills and snaps off the front of the bone on [user]'s arm, leaving behind a strange, gun-like structure!"))
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/chilling/pink
	colour = "pink"
	effect_desc = ""

/obj/item/slimecross/chilling/pink/do_effect(mob/user)
	user.visible_message(span_notice("[src] cracks like an egg, and an adorable puppy comes tumbling out!"))
	new /mob/living/simple_animal/pet/dog/corgi/puppy/slime(get_turf(user))
	..()

/obj/item/slimecross/chilling/gold
	colour = "gold"
	effect_desc = ""

/obj/item/slimecross/chilling/gold/do_effect(mob/user)
	user.visible_message(span_notice("[src] lets off golden light as it melts and reforms into an egg-like device!"))
	new /obj/item/capturedevice(get_turf(user))
	..()

/obj/item/slimecross/chilling/oil
	colour = "oil"
	effect_desc = ""

/obj/item/slimecross/chilling/oil/do_effect(mob/user)
	user.visible_message(span_danger("[src] begins to shake with muted intensity!"))
	addtimer(CALLBACK(src, PROC_REF(boom)), 50)

/obj/item/slimecross/chilling/oil/proc/boom()
	explosion(get_turf(src), -1, -1, 10, 0) //Large radius, but mostly light damage, and no flash.
	qdel(src)

/obj/item/slimecross/chilling/black
	colour = "black"
	effect_desc = ""

/obj/item/slimecross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message(span_notice("[src] crystallizes along [user]'s skin, turning into metallic scales!"))
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/golem/random)
	..()

/obj/item/slimecross/chilling/lightpink
	colour = "light pink"
	effect_desc = ""

/obj/item/slimecross/chilling/lightpink/do_effect(mob/user)
	user.visible_message(span_notice("[src] blooms into a beautiful flower!"))
	new /obj/item/clothing/head/peaceflower(get_turf(user))
	..()

/obj/item/slimecross/chilling/adamantine
	colour = "adamantine"
	effect_desc = ""

/obj/item/slimecross/chilling/adamantine/do_effect(mob/user)
	user.visible_message(span_notice("[src] creaks and breaks as it shifts into a heavy set of armor!"))
	new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user))
	..()
