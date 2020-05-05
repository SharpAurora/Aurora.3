/turf/unsimulated/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	footstep_sound = "sand"
	gender = PLURAL

/turf/unsimulated/beach/sand
	name = "sand"
	icon_state = "sand"
	footstep_sound = "sand"

/turf/unsimulated/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"
	footstep_sound = "sand"

/turf/unsimulated/beach/water
	name = "water"
	icon_state = "water"
	footstep_sound = "water"

/turf/unsimulated/beach/water/Initialize()
	. = ..()
	add_overlay(image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1))

/turf/unsimulated/beach/water/hotspring
	name = "hot water"
	icon_state = "poolwater"
	temperature = 309	//Typical hotspring temperature.

/turf/unsimulated/beach/water/hotspring/Initialize()
	. = ..()
	cut_overlays()
	add_overlay(image(icon,"icon_state"="poolwater_over","layer"=MOB_LAYER+0.1))

/turf/unsimulated/beach/water/ice
	name = "ice water"
	icon_state = "water5"
	temperature = 275

/turf/unsimulated/beach/water/ice/Initialize()
	. = ..()
	cut_overlays()
	add_overlay(image(icon,"icon_state"="water5_over","layer"=MOB_LAYER+0.1))