/mob/living/simple_animal/skikja
	name = "skikja"
	desc = "A creature similar to a stingray. Known for its excellent camoflague and tendency to startle people who come too close. They float in a way similar to space carp, and are known to be quite shy."
	icon = 'icons/mob/npc/waystation.dmi'
	health = 30
	maxHealth = 30
	icon_state = "manta"
	icon_living = "manta"
	icon_dead = "manta_dead"
	icon_rest = "manta_rest"
	icon_sleep = "manta_sleep"
	var/icon_hide = "manta_buried"
	holder_type = /obj/item/holder/skikja

	speak = list("Blorble!", "Brrrrbll?", "Fweee!")
	speak_chance = 1
	speak_emote = list("blubs", "glibs", "whistles")
	emote_hear = list("blubs", "glibs", "whistles")
	emote_see = list("undulates.", "flaps its little wings.", "waggles around.")

	meat_amount = 1
	meat_type = /obj/item/reagent_containers/food/snacks/meat/skikja

	response_help   = "brushes"
	response_disarm = "pushes"
	response_harm   = "wounds"
	harm_intent_damage = 5

	minbodytemp = 190
	maxbodytemp = 325
	cold_damage_per_tick = 0.5	

	friendly = "rubs against"

	//Slower digestion and nutrition loss
	max_nutrition = 35
	metabolic_factor = 0.8
	nutrition_step = 0.1 
	bite_factor = 0.3
	digest_factor = 0.1 
	var/next_search //next time we look for food

	stop_automated_movement_when_pulled = FALSE

	scan_range = 7

	can_nap = TRUE
	canbrush = TRUE 
	brush = /obj/item/reagent_containers/glass/rag 

	flying = TRUE 

	faction = FACTION_SNOW

	var/static/list/hideable_turfs = list(/turf/simulated/floor/snow)
	var/hiding
	var/flee_target
	var/do_reveal_timer
	var/obj/item/reagent_containers/food/snacks/food_target

/mob/living/simple_animal/skikja/update_icons()
	if(hiding && stat != DEAD)
		icon_state = icon_hide
	else
		..()

/mob/living/simple_animal/skikja/Allow_Spacemove(var/check_drift = 0)
	return TRUE

/mob/living/simple_animal/skikja/fall_impact()
	visible_message(SPAN_NOTICE("\The [src] gently floats to a stop."))
	return FALSE

/mob/living/simple_animal/skikja/proc/bury_self(var/turf/T)
	world << "Attempting bury_self in [T]"
	if(!isturf(loc))
		return FALSE
	if(food_target)
		return
	if(is_type_in_list(T, hideable_turfs))
		world << "[T] in hideable turfs, burying"
		visible_message(SPAN_NOTICE("\The [src] lays against the [T] and shakes itself back and forth. Soon, it is entirely camoflauged against it."))
		resting = TRUE
		hiding = TRUE
		stop_automated_movement = TRUE
		icon_state = icon_hide
		do_reveal_timer = addtimer(CALLBACK(src, .proc/reveal_self), rand(900, 1500), TIMER_STOPPABLE)

/mob/living/simple_animal/skikja/proc/handle_hidden()
	food_search()
	return

/mob/living/simple_animal/skikja/proc/food_search()
	if(flee_target || world.time < next_search) //Too scared to care, or we lost interest recently
		return FALSE
	if(food_target)
		if(resting || hiding || flee_target)
			food_target = null
			return
		if(prob(95) || (nutrition / max_nutrition) <= 0.25)
			world << "Checking out the food"
			walk_to(src, food_target.loc, 1)
			if(Adjacent(food_target.loc))
				if(prob(20))
					visible_message(SPAN_NOTICE("\The [src] sniffs \the [food_target] curiously."))
				if(prob(10))
					say(pick(speak))
				if(isturf(food_target.loc) && (nutrition / max_nutrition) <= 0.5)
					UnarmedAttack(food_target)
		else
			world << "lost interest in food target"
			say(pick(speak))
			walk_away(src, food_target.loc, 2, 2)
			food_target = null
			next_search = world.time + rand(300, 900)
		return
	var/list/food_curiosity = list()
	for(var/obj/item/reagent_containers/food/snacks/G in orange(src, scan_range))
		if(istype(G, /obj/item/reagent_containers/food/snacks/meat))
			continue
		food_curiosity += G
		for(var/mob/living/carbon/human/H in orange(src, scan_range))
			if(istype(H.l_hand, G))
				world << "Found [G] on [H]"
				food_curiosity += G
			if(istype(H.r_hand, G))
				world << "Found [G] on [H]"
				food_curiosity += G
	if(prob(30) && food_curiosity.len)
		world << "Food searching"
		food_target = pick(food_curiosity)
		world << "food is [food_target]"
		reveal_self()
		var/distance = get_dist(src, food_target.loc)
		var/mob/living/carbon/human/M
		if(food_target.loc == M)
			walk_to(src, M, distance)
			visible_message(SPAN_NOTICE("\The [src] moves towards \the [M], sniffing the air curiously."))

		else
			walk_to(src, get_turf(food_target), distance)
			visible_message(SPAN_NOTICE("\The [src] moves towards \the [food_target], sniffing the air curiously."))


/mob/living/simple_animal/skikja/proc/reveal_self(var/startled)
	if(!hiding)
		return
	hiding = FALSE
	restore_self()
	var/turf/T = get_turf(src)
	if(startled)
		visible_message(SPAN_WARNING("\The [src] bursts up from \the [T]!"))
		say("Blirblll!!")
		handle_flee_target()
	else
		visible_message(SPAN_WARNING("\The [src] gently lifts itself from \the [T] and floats in the air."))

/mob/living/simple_animal/skikja/proc/restore_self()
	resting = FALSE
	icon_state = initial(icon_state)

/mob/living/simple_animal/skikja/think()
	if(hiding)
		handle_hidden()
	else
		if(flee_target)
			handle_flee_target()
		else
			if(!resting)
				restore_self()
				food_search()
				if(prob(10))
					bury_self(get_turf(src))
			else if(prob(10))
				lay_down()
			..()

/mob/living/simple_animal/skikja/Crossed(var/atom/movable/AM)
	..()
	if(hiding)
		if(isliving(AM))
			if(isanimal(AM))
				var/mob/living/simple_animal/SA = AM
				if(SA.flying)
					return
			set_flee_target(AM)
		else
			set_flee_target(get_turf(src))
		reveal_self(TRUE)


/mob/living/simple_animal/skikja/proc/handle_flee_target()
	world << "handling flee target"
	//see if we should stop fleeing
	if(flee_target && !(flee_target in view(src)))
		flee_target = null
		stop_automated_movement = FALSE
		INVOKE_ASYNC(src, .proc/bury_self, get_turf(src)) //hide after running, poor thing
		world << "Should have nulled flee target. Flee target: [flee_target]"
		return

	if(flee_target)
		food_target = null //fleeing is more important than eating
		if(prob(25)) 
			say("Blibblbl!!")
		stop_automated_movement = TRUE
		walk_away(src, flee_target, 7, 2)
		deltimer(do_reveal_timer)
	//This is mostly a precaution against infinite flee loops
	else
		flee_target = null
		stop_automated_movement = FALSE

/mob/living/simple_animal/skikja/proc/set_flee_target(atom/A)
	if(A)
		flee_target = A
		turns_since_move = 5

/mob/living/simple_animal/skikja/attackby(var/obj/item/O, var/mob/user)
	. = ..()
	if(O.force)
		if(resting)
			poke(1)
		set_flee_target(user ? user : get_turf(src))

/mob/living/simple_animal/skikja/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.a_intent == I_HURT)
		set_flee_target(M)

/mob/living/simple_animal/skikja/ex_act(var/severity = 2.0)
	. = ..()
	if(src)
		set_flee_target(get_turf(src))

/mob/living/simple_animal/skikja/bullet_act(var/obj/item/projectile/proj)
	. = ..()
	if(stat != DEAD)
		if(resting)
			poke(1)
		set_flee_target(proj.firer? proj.firer : get_turf(src))

/mob/living/simple_animal/skikja/hitby(atom/movable/AM)
	. = ..()
	if(resting)
		poke(1)
	set_flee_target(AM.thrower? AM.thrower : get_turf(src))

/mob/living/simple_animal/skikja/attempt_grab(var/mob/living/grabber)
	var/prob_mod = 1
	if(ishuman(grabber))
		var/mob/living/carbon/human/H = grabber
		if(H.species)
			prob_mod = H.species.resist_mod
	restore_self()
	if(prob(30 * prob_mod))
		return TRUE
	else
		visible_message(SPAN_WARNING("\The [src] slips away from \the [grabber]!"))
		set_flee_target(grabber)
		handle_flee_target()
		return FALSE


//Fireflies, mostly copied from bee code
/mob/living/simple_animal/infernofly
	name = "infernoflies"
	desc = "Harmless bioluminescent insects that pulse light to attract mates. These also produce heat and therefore are frequently found in cold climates."
	icon = 'icons/mob/npc/waystation.dmi'
	icon_state = "infernofly1"
	icon_dead = "infernofly1"
	mob_size = 0.5
	mob_swap_flags = null
	mob_push_flags = null
	unsuitable_atoms_damage = 2.5
	maxHealth = 15
	density = FALSE
	var/strength = 1
	var/loner = FALSE
	var/name_single = "infernofly"
	pass_flags = PASSTABLE
	turns_per_move = 6
	flying = TRUE
	holder_type = /obj/item/holder/infernofly
	faction = "Ambient"

/mob/living/simple_animal/infernofly/Initialize()
	. = ..()
	strength = rand(1,7)
	update_icons()

/mob/living/simple_animal/infernofly/Destroy()
	set_light(null)
	. = ..()

/mob/living/simple_animal/infernofly/death()
	if (!QDELING(src))
		strength -= rand(1, 2)
		if (strength <= 0)
			if(prob(35))
				if(!loner)
					visible_message(SPAN_WARNING("\The [src] completely scatter."))
			qdel(src)
			return
		else
			health = maxHealth
			if(prob(35))
				visible_message(SPAN_WARNING("\The [src] start to thin out a little."))

		update_icons()
	else
		..()

/mob/living/simple_animal/infernofly/think()
	..()
	if (stat != CONSCIOUS)
		return

	//ambient
	if(prob(1))
		if(loner)
			visible_message(SPAN_GOOD(pick("\The [src] lights up briefly.","The light of \the [src] blinks.")))
		else
			visible_message(SPAN_GOOD(pick("\The [src] light up in a short pattern.","The lights of \the [src] blink.")))

	//finding friends
	for(var/mob/living/simple_animal/infernofly/B in get_turf(src))
		if(B == src)
			continue
		if(strength > B.strength)
			strength += B.strength
			B.strength = 0
			qdel(B)
			update_icons()
		if(strength == B.strength)
			if(prob(50))
				strength += 1
				B.strength -= 1
			else
				strength -= 1
				B.strength += 1
			update_icons()

/mob/living/simple_animal/infernofly/update_icons()
	if(strength == 1)
		name = name_single
		loner = TRUE
	else
		name = initial(name)
		loner = FALSE
	if(strength <= 4)
		icon_state = "infernofly[round(strength,1)]"
	else
		icon_state = "infernofly_swarm"
	//setting lights
	var/light_range = min(1.4 + (strength/7), 4)
	set_light(light_range, 0.8, LIGHT_COLOR_YELLOW)
	
//Can't actually grab these lads, but you can try to catch them!
/mob/living/simple_animal/infernofly/attempt_grab(var/mob/living/grabber)
	if(prob(strength*10) || (loner && prob(50)))
		grabber.visible_message(SPAN_NOTICE("\The [grabber] catches \an [name_single]!"), SPAN_NOTICE("You snatch \an [name_single]!"))
		if(!loner)
			strength -= 1
			var/mob/living/simple_animal/infernofly/single/fly = new(get_turf(src))
			fly.get_scooped(grabber)
			update_icons()
		else
			get_scooped(grabber)

	else
		to_chat(grabber, SPAN_NOTICE("You try to grab \an [name_single], but it slips away."))
		step_away(src, grabber, 1)

	return FALSE

/mob/living/simple_animal/infernofly/attempt_pull(var/mob/living/grabber)
	return attempt_grab(grabber)

/mob/living/simple_animal/infernofly/single
	loner = TRUE

/mob/living/simple_animal/infernofly/single/Initialize()
	. = .. ()
	strength = 1
	update_icons()