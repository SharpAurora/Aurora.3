/mob/living/simple_animal/hostile/retaliate/goat/boar
	name = "tundra boar"
	desc = "A large-tusked mammal with heavy fur. Not usually kept as stock due to their tendency to have furious mood swings."
	icon = 'icons/mob/npc/waystation.dmi'
	icon_state = "boar"
	icon_living = "boar"
	icon_dead = "boar_dead"
	speak = list("Hrrumpf?","Hrunmpf.", "Squoiiink!")
	speak_emote = list("grunts")
	emote_hear = list("grunts", "chuffs", "snorts")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	angry_emote = "stamps their foot and squeals angrily!"
	speak_chance = 1
	meat_type = /obj/item/reagent_containers/food/snacks/meat
	meat_amount = 8
	mob_size = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = FACTION_SNOW
	attacktext = "gored"
	maxHealth = 60
	melee_damage_lower = 7
	melee_damage_upper = 17
	emote_sounds = null
	has_udder = FALSE

	butchering_products = list(/obj/item/stack/material/animalhide = 5)