/obj/structure/ice_crystal
	name = "ice crystal formation"
	desc = "Sculpted lovingly by mother nature. The air around it is frigid."
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "crystal_1"
	anchored = TRUE
	density = TRUE
	var/cooling_power = 52000
	var/do_process = TRUE

/obj/structure/ice_crystal/Initialize()
	. = ..()
	icon_state = pick("crystal_1", "crystal_2", "crystal_3")
	set_light(1.8, 1, LIGHT_COLOR_CYAN)
	if(do_process)
		START_PROCESSING(SSprocessing, src)

/obj/structure/ice_crystal/Destroy()
	set_light(0)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structure/ice_crystal/process()
	if(!do_process)
		STOP_PROCESSING(SSprocessing, src)
	var/datum/gas_mixture/env = loc.return_air()
	if(env && abs(env.temperature - (T0C - 28)) > 1)
		var/transfer_moles = 0.3 * env.total_moles
		var/datum/gas_mixture/removed = env.remove(transfer_moles)

		if(removed)
			var/heat_transfer = removed.get_thermal_energy_change(T0C - 28)
			if(heat_transfer < 0)
				heat_transfer = min(abs(heat_transfer), cooling_power)
				removed.add_thermal_energy(-heat_transfer)

			env.merge(removed)

/obj/structure/ice_crystal/no_process
	do_process = FALSE

