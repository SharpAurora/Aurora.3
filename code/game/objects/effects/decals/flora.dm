/obj/effect/decal/flora
	name = "bush"
	gender = PLURAL
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowgrass1bb"
	anchored = TRUE

/obj/effect/decal/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	mouse_opacity = 0

/obj/effect/decal/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/effect/decal/flora/grass/brown/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/effect/decal/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/effect/decal/flora/grass/green/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/effect/decal/flora/grass/both
	icon_state = "snowgrassall1"

/obj/effect/decal/flora/grass/both/Initialize()
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"

//Jungle grass
/obj/effect/decal/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa"

/obj/effect/decal/flora/grass/jungle/b
	icon_state = "grassb"

//bushes
/obj/effect/decal/flora/bush/snow
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"

/obj/effect/decal/flora/bush/snow/Initialize()
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/effect/decal/flora/cave
	name = "geistlily"
	desc = "A type of plant the grows in deep caverns, known for its purple color and luminous bulbs."
	icon_state = "monolith"

/obj/effect/decal/flora/cave/Initialize()
	. = ..()
	icon_state = pick("monolith", "sprouts1", "tendril1", "tendril2") 

/obj/effect/decal/flora/cave/luminous
	icon_state = "geistlily"

/obj/effect/decal/flora/cave/luminous/Initialize()
	. = ..()
	icon_state = pick("geistlily", "eye", "cyst")
	set_light(2, 2, LIGHT_COLOR_VIOLET)