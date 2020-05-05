// Used for creating the exchange areas.
/area/turbolift
	name = "Turbolift"
	base_turf = /turf/simulated/open
	requires_power = 0
	station_area = 1
	sound_env = SMALL_ENCLOSED

	var/lift_floor_label = null
	var/lift_floor_name = null
	var/lift_announce_str = "Ding!"
	var/arrival_sound = 'sound/machines/ding.ogg'

	var/announce_speak = TRUE	//If TRUE, precedes lift_announce_str with "The elevator announces." Do FALSE to have the arrival message display without that prefix