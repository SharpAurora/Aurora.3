/mob/living/simple_animal/hostile/angler
	name = "cave angler"
	desc = "A deep-cavern dweller that baits targets by mimicking the light of native xenoflora. When they come too close, they spring out and attack with incredible speed."
	icon = 'icons/mob/npc/waystation.dmi'
	icon_state = "angler"
	icon_living = "angler"
	icon_rest = "angler-rest"
	icon_dead = "angler-rest"

	speak_chance = FALSE
	emote_sounds = list('sound/species/shadow/grue_screech.ogg', 'sound/species/shadow/grue_growl.ogg')
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 8
	
	meat_amount = 4
	meat_type = /obj/item/reagent_containers/food/snacks/dwellermeat

	maxHealth = 85
	health = 85

	response_help   = "prods"
	response_disarm = "pushes"
	response_harm   = "hits"

	blood_type = "#0f1038" 
	faction = FACTION_CAVERN
	attacktext = "rends"
	attack_emote = "shrieks at"
	melee_damage_lower = 10
	melee_damage_upper = 16

	minbodytemp = 150
	maxbodytemp = 320

	speed = 1
	butchering_products = list(/obj/item/stack/material/animalhide/lizard = 2)


	patient = TRUE
	wander_time = 600 //How long we'll wander for. This is the minimum time, 2 times this is max time
	patience = 1800 //How long we'll rest for. 

/mob/living/simple_animal/hostile/angler/Initialize()
	. = ..()
	set_light(1.8, 1, LIGHT_COLOR_YELLOW)

/mob/living/simple_animal/hostile/angler/Destroy()
	. = ..()
	set_light(0)

/mob/living/simple_animal/hostile/angler/AttackingTarget()
	if(prob(20))
		make_noise()
	return ..()

/mob/living/simple_animal/hostile/giant_spider/iceking
	name = "ice king"
	desc = "A huge predator that uses camoflauge to hunt prey. This type of spider is a solitary species, and is unusual in that the males are as large and aggressive as the females. Only the females are venomous."
	icon = 'icons/mob/npc/waystation.dmi'
	icon_state = "iceking"
	icon_living = "iceking"
	icon_dead = "iceking_dead"
	icon_rest = "iceking_rest"
	maxHealth = 225
	health = 225
	melee_damage_lower = 18
	melee_damage_upper = 22
	cold_damage_per_tick = 5
	minbodytemp = 150
	maxbodytemp = 310
	poison_per_bite = 3 //stronger but not as much poison

	mob_size = 9

	patient = TRUE
	wander_time = 300 
	patience = 2400
	resting_view = 5 //better at sensing targets

/mob/living/simple_animal/hostile/giant_spider/iceking/Initialize()
	. = ..()
	if(prob(50))
		poison_per_bite = 0
	else
		poison_type = pick("toxin", "panotoxin", "dextrotoxin")

/mob/living/simple_animal/hostile/giant_spider/iceking/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "This one has the markings of a [poison_per_bite ? "female" : "male"].")
