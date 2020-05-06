/obj/turbolift_map_holder/waystation/mine_shaft
	name = "Waystation lift placeholder - Mine Shaft"
	dir = NORTH

	depth = 3
	lift_size_x = 4
	lift_size_y = 4

	areas_to_use = list(
		/area/turbolift/mine_cavern,
		/area/turbolift/mine_transit,
		/area/turbolift/mine_surface
		)

	wall_type =  /turf/simulated/wall/rusted 
	floor_type = /turf/simulated/floor/wood 
	door_type =  /obj/machinery/door/airlock/lift 

/area/turbolift/mine_cavern
	name = "Caverns"
	lift_announce_str = "<I>The shaft elevator shudders to a halt just above the ground level. After a moment, it lurches and thumps against the ground, jostling its occupants.</I>"

	lift_floor_label = "Below Surface"
	lift_floor_name = "Below Surface"
	base_turf = /turf/simulated/floor/plating

	sound_env = TUNNEL_ENCLOSED
	arrival_sound = 'sound/machines/airlock_open_force.ogg'
	announce_speak = FALSE

/area/turbolift/mine_transit
	name = "Cavern Transit"
	lift_announce_str = "<I>The lift creaks and groans as it moves through the seemingly endless mine shaft. It's a bumpy ride, and the floor sways just enough to be noticeable.</I>"

	lift_floor_label = "Abandoned"
	lift_floor_name = "Abandoned"

	sound_env = TUNNEL_ENCLOSED
	arrival_sound = 'sound/machines/airlock_open_force.ogg'
	announce_speak = FALSE

/area/turbolift/mine_surface
	name = "Surface"
	lift_announce_str = "<I>The lift creaks heavily as it's pulled upward, locking in place with a hearty shudder.</I>"

	lift_floor_label = "Planet Surface"
	lift_floor_name = "Planet Surface"

	sound_env = TUNNEL_ENCLOSED
	arrival_sound = 'sound/machines/airlock_open_force.ogg'
	announce_speak = FALSE