
/datum/job/roguetown/priest
	title = "Priest"
	flag = PRIEST
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = JCOLOR_CHURCH
	f_title = "Priestess"
	allowed_races = RACES_TOLERATED_UP
	allowed_patrons = ALL_DIVINE_PATRONS
	allowed_sexes = list(MALE, FEMALE)
	tutorial = "The Divine is all that matters in a world of the immoral. The Weeping God left his children to rule over us mortals and you will preach their wisdom to any who still heed their will. The faithless are growing in number, it is up to you to shepard them to a Gods-fearing future."
	whitelist_req = FALSE

	spells = list(/obj/effect/proc_holder/spell/self/convertrole/templar, /obj/effect/proc_holder/spell/self/convertrole/monk)
	outfit = /datum/outfit/job/roguetown/priest

	display_order = JDO_PRIEST
	give_bank_account = 115
	min_pq = 8
	max_pq = null

/datum/outfit/job/roguetown/priest
	allowed_patrons = list(/datum/patron/divine/astrata)

/datum/outfit/job/roguetown/priest/pre_equip(mob/living/carbon/human/H)
	..()
	H.virginity = TRUE
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	head = /obj/item/clothing/head/roguetown/priestmask
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	beltl = /obj/item/keyring/priest
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	id = /obj/item/clothing/ring/active/nomag
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/natural/worms/leech/cheele = 1, //little buddy
	)
	ADD_TRAIT(H, TRAIT_CHOSEN, TRAIT_GENERIC)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/alchemy, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 5, TRUE)
		if(H.age == AGE_OLD)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 3)
		H.change_stat("constitution", -1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", -1)
	var/datum/devotion/C = new /datum/devotion(H, H.patron) // This creates the cleric holder used for devotion spells
	C.grant_spells_priest(H)
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)

	H.verbs |= /mob/living/carbon/human/proc/coronate_lord
	H.verbs |= /mob/living/carbon/human/proc/churchexcommunicate
	H.verbs |= /mob/living/carbon/human/proc/churchannouncement
	H.verbs |= /mob/living/carbon/human/proc/churchhereticsbrand
//	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
//		H.underwear = "Femleotard"
//		H.underwear_color = CLOTHING_BLACK
//		H.update_body()

/mob/living/carbon/human/proc/coronate_lord()
	set name = "Coronate"
	set category = "Priest"
	if(!mind)
		return
	if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
		to_chat(src, span_warning("I need to do this in the chapel."))
		return FALSE
	for(var/mob/living/carbon/human/HU in get_step(src, src.dir))
		if(!HU.mind)
			continue
		if(HU.mind.assigned_role == "King")
			continue
		if(!HU.head)
			continue
		if(!istype(HU.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
			continue

		//Abdicate previous King
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.mind)
				if(HL.mind.assigned_role == "King" || HL.mind.assigned_role == "Queen Consort")
					HL.mind.assigned_role = "Towner" //So they don't get the innate traits of the king
			//would be better to change their title directly, but that's not possible since the title comes from the job datum
			if(HL.job == "King")
				HL.job = "King Emeritus"
			if(HL.job == "Queen Consort")
				HL.job = "Queen Dowager"
			SSjob.type_occupations[/datum/job/roguetown/lord].remove_spells(HL)

		//Coronate new King (or Queen)
		HU.mind.assigned_role = "King"
		HU.job = "King"
		SSjob.type_occupations[/datum/job/roguetown/lord].add_spells(HU)

		switch(HU.gender)
			if("male")
				SSticker.rulertype = "King"
			if("female")
				SSticker.rulertype = "Queen"
		SSticker.rulermob = HU
		var/dispjob = mind.assigned_role
		removeomen(OMEN_NOLORD)
		say("By the authority of the gods, I pronounce you Ruler of all Rockhill!")
		priority_announce("[real_name] the [dispjob] has named [HU.real_name] the inheritor of ROCKHILL!", title = "Long Live [HU.real_name]!", sound = 'sound/misc/bell.ogg')

/mob/living/carbon/human/proc/churchexcommunicate()
	set name = "Excommunicate"
	set category = "Priest"
	if(stat)
		return
	var/inputty = input("Excommunicate someone, removing their ability to use miracles... (excommunicate them again to remove it)", "Sinner Name") as text|null
	if(inputty)
		if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
			to_chat(src, span_warning("I need to do this from the Church's chapel."))
			return FALSE
		if(inputty in GLOB.excommunicated_players)
			GLOB.excommunicated_players -= inputty
			priority_announce("[real_name] has forgiven [inputty]. Their patron hears their prayer once more!", title = "Hail the Ten!", sound = 'sound/misc/bell.ogg')
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name == inputty)
					H.remove_stress(/datum/stressevent/psycurse)
					H.devotion.recommunicate()
			return
		var/found = FALSE
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.real_name == inputty)
				found = TRUE
				H.add_stress(/datum/stressevent/psycurse)
				H.devotion.excommunicate()
		if(!found)
			return FALSE

		GLOB.excommunicated_players += inputty
		priority_announce("[real_name] has excommunicated [inputty] from the Church!", title = "SHAME", sound = 'sound/misc/excomm.ogg')

/mob/living/carbon/human/proc/churchhereticsbrand()
	set name = "Brand Heretic"
	set category = "Priest"
	if(stat)
		return
	var/inputty = input("Brand someone as a foul heretic... (brand them again to remove it)", "Sinner Name") as text|null
	if(inputty)
		if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
			to_chat(src, span_warning("I need to do this from the Church."))
			return FALSE
		if(inputty in GLOB.heretical_players)
			GLOB.heretical_players -= inputty
			priority_announce("[real_name] has removed the Heretic's Brand from [inputty]. Once more walk in the light!", title = "Hail the Ten!", sound = 'sound/misc/bell.ogg')
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name == inputty)
					H.remove_stress(/datum/stressevent/psycurse)
			return
		var/found = FALSE
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H == src)
				continue
			if(H.real_name == inputty)
				found = TRUE
				H.add_stress(/datum/stressevent/psycurse)
		if(!found)
			return FALSE
		GLOB.heretical_players += inputty
		priority_announce("[real_name] has placed a Heretic's Brand upon [inputty]!", title = "SHAME", sound = 'sound/misc/excomm.ogg')

/mob/living/carbon/human
	COOLDOWN_DECLARE(church_announcement)

/mob/living/carbon/human/proc/churchannouncement()
	set name = "Announcement"
	set category = "Priest"

	if(!COOLDOWN_FINISHED(src, church_announcement))
		to_chat(src, span_warning("I should wait..."))
		return

	if(stat)
		return FALSE

	var/inputty = input("Make an announcement", "ROGUETOWN") as text|null
	if(!inputty)
		return FALSE

	if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
		to_chat(src, span_warning("I need to do this from the chapel."))
		return FALSE

	priority_announce("[inputty]", title = "The Priest Speaks", sound = 'sound/misc/bell.ogg')
	COOLDOWN_START(src, church_announcement, 30 SECONDS)

/obj/effect/proc_holder/spell/self/convertrole/templar
	name = "Recruit Templar"
	new_role = "Templar"
	recruitment_faction = "Templars"
	recruitment_message = "Serve the ten, %RECRUIT!"
	accept_message = "FOR THE TEN!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/monk
	name = "Recruit Acolyte"
	new_role = "Acolyte"
	recruitment_faction = "Church"
	recruitment_message = "Serve the ten, %RECRUIT!"
	accept_message = "FOR THE TEN!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/invoked/solar_smite
	name = "Solar Smite"
	overlay_state = "solarsmite"
	releasedrain = 100
	chargedrain = 0
	chargetime = 1 SECONDS
	range = 8
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = /datum/looping_sound/invokeholy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/churn.ogg'
	invocation = "ASTRATA SMITE YOU! BURN!!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 60 SECONDS
	miracle = TRUE
	devotion_cost = 100
	//explosion values
	var/exp_heavy = 0
	var/exp_light = 4
	var/exp_flash = 16

/obj/effect/proc_holder/spell/invoked/solar_smite/cast(list/targets, mob/user = usr)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/L = targets[1]
		user.visible_message("<font color='yellow'>[user] points at [L]!</font>")
		if(GLOB.tod == "night")
			if(L.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
				L.adjust_fire_stacks(12)
				L.IgniteMob()
				L.adjustFireLoss(60)
				explosion(L, -1, 0, 2, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
				return TRUE
			else
				L.adjust_fire_stacks(8)
				L.IgniteMob()
				L.adjustFireLoss(40)
				explosion(L, -1, 0, 2, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
				return TRUE
		if(GLOB.tod == "dawn" || "dusk")
			if(L.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
				L.visible_message(span_danger("[L] is unmade by holy light!"), span_userdanger("I'm unmade by holy light!"))
				explosion(L, -1, 0, 3, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
				L.gib()
				return TRUE
			else
				L.adjust_fire_stacks(10)
				L.IgniteMob()
				L.adjustFireLoss(60)
				explosion(L, -1, 0, 3, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
				return TRUE
		else
			if(L.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
				L.visible_message(span_danger("[L] is unmade by holy light!"), span_userdanger("I'm unmade by holy light!"))
				explosion(L, -1, exp_heavy, exp_light, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
				L.gib()
				return TRUE
			else
				L.adjust_fire_stacks(12)
				L.IgniteMob()
				L.adjustFireLoss(80)
			explosion(L, -1, exp_heavy, exp_light, exp_flash, 0, soundin = 'sound/misc/lava_death.ogg')
			return TRUE
		return FALSE
