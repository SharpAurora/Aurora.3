//cave dwelling dragon
/mob/living/simple_animal/hostile/retaliate/blind_wyvern
	name = "blind wyvern"
	desc = "An eyeless reptile with huge wings. It looks straight out of myth."
	icon = 'icons/mob/npc/cavern.dmi'
	icon_state = "dragon" //icons by Kyres1
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	smart = TRUE
	turns_per_move = 3
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	meat_type = /obj/item/reagent_containers/food/snacks/meat/wyvern
	meat_amount = 4
	mob_size = 20

	health = 340
	maxHealth = 340
	melee_damage_lower = 24
	melee_damage_upper = 30
	attacktext = "chomped"
	attack_sound = 'sound/weapons/bite.ogg'
	speed = 4
	destroy_surroundings = 1

	emote_see = list("stares","flaps it's wings aggressively","roars")
	emote_sounds = list('sound/effects/creatures/bear_loud_1.ogg','sound/effects/creatures/bear_loud_2.ogg')
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_NOLIGHTING

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = FACTION_CAVERN

	flying = TRUE