/mob/living/simple_animal/hostile/angler
	name = "cave angler"
	desc = "A deep-cavern dweller that baits targets by mimicking the light of native xenoflora. When they come too close, they spring out and attack with incredible speed."
	icon = 'icons/mob/npc/waystation.dmi'
	icon_state = "angler"
	icon_living = "angler"
	icon_resting = "angler-rest"
	icon_dead = "angler-rest"

	speak_chance = FALSE
	emote_sounds = list('sound/species/shadow/grue_screech.ogg', 'sound/species/shadow/grue_growl.ogg')
	
	meat_amount = 4
	meat_type = /obj/item/reagent_containers/food/snacks/carpmeat

	maxHealth = 85
	health = 85

	response_help   = "prods"
	response_disarm = "pushes"
	response_harm   = "hits"

	blood_type = "#0f1038" //Blood colour for impact visuals.
	faction = FACTION_CAVERN
	attacktext = "rends"
	attack_emote = "shrieks at"
	melee_damage_lower = 10
	melee_damage_upper = 16

	minbodytemp = 150
	maxbodytemp = 320

	speed = 1
	butchering_products = list()
	var/next_bide //when we decide to go back into watch and wait mode
	var/minimum_wait //the minimum time we bide for

/mob/living/simple_animal/hostile/angler/think()
	if(stance == HOSTILE_STANCE_IDLE && world.time >= next_bide)
		bide()
	..()

/mob/living/simple_animal/hostile/angler/proc/bide()
	if(!resting) //If we aren't resting, we rest, and bide our time for prey
		stop_automated_movement = TRUE
		resting = TRUE
		minimum_wait = world.time + rand(1800, 3000)
	else
		if(prob(1) && world.time >= minimum_wait) //If we ARE biding our time and a very small chance, we get up and wander a bit.
			resting = FALSE
			stop_automated_movement = FALSE
			next_bide = world.time + rand(600, 1200)
	update_icons()

/mob/living/simple_animal/hostile/angler/see_target()
	var/range = 10
	if(resting)
		range = 3
	return (target_mob in view(range, src)) ? (TRUE) : (FALSE)

/mob/living/simple_animal/hostile/angler/MoveToTarget()
	if(resting)
		resting = FALSE
		update_icons()
	..()

/mob/living/simple_animal/hostile/angler/AttackingTarget()
	if(prob(20))
		make_noise()
	return ..()