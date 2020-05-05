#define MAX_ACTIVE_BONFIRE_LIMIT	15

var/global/list/total_active_bonfires = list()

/obj/structure/bonfire
	name = "bonfire"
	desc = "A large pile of wood, ready to be burned."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "bonfire"
	anchored = TRUE
	density = FALSE
	light_color = LIGHT_COLOR_FIRE
	var/fuel = 2000
	var/max_fuel = 2000
	var/on_fire = FALSE
	var/safe = FALSE
	var/obj/machinery/appliance/bonfire/cook_machine
	var/list/burnable_materials = list(MATERIAL_WOOD = 200, MATERIAL_WOOD_LOG = 400, MATERIAL_WOOD_BRANCH = 40, MATERIAL_COTTON = 20, MATERIAL_CLOTH = 50, MATERIAL_CARPET = 20, MATERIAL_CARDBOARD = 35)
	var/list/burnable_other = list(/obj/item/ore/coal = 750, /obj/item/torch_head = 50, /obj/item/torch_handle = 20) //For items without material/default material
	var/heat_range = 5 //Range in which it will heat other people
	var/heating_power
	var/last_ambient_message
	var/burn_out = TRUE //Whether or not it deletes itself when fuel is depleted

/obj/structure/bonfire/Initialize()
	. = ..()
	fuel = rand(1000, 2000)
	create_reagents(120)

/obj/structure/bonfire/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	cook_machine = null
	total_active_bonfires -= src
	. = ..()

/obj/structure/bonfire/examine(mob/user)
	..()
	if(get_dist(src, user) > 2)
		return
	if(on_fire)
		switch(fuel)
			if(0 to 200)
				to_chat(user, "\The [src] is burning weakly.")
			if(200 to 600)
				to_chat(user, "\The [src] is gently burning.")
			if(600 to 900)
				to_chat(user, "\The [src] is burning steadily.")
			if(900 to 1300)
				to_chat(user, "The flames are dancing wildly!")
			if(1300 to 2000)
				to_chat(user, "The fire is roaring!")
	if(!cook_machine)
		return
	cook_machine.list_contents(user)

/obj/structure/bonfire/update_icon()
	if(on_fire)
		if(fuel < 200)
			icon_state = "[initial(icon_state)]_warm"
		else
			icon_state = "[initial(icon_state)]_fire"
	else
		icon_state = initial(icon_state)

/obj/structure/bonfire/attack_hand(var/mob/user)
	if(!cook_machine)
		return
	if (cook_machine.cooking_objs.len)
		if (cook_machine.removal_menu(user))
			return
		else
			..()

/obj/structure/bonfire/attackby(obj/item/W, mob/user)
	if(isflamesource(W) && !on_fire) // needs to go last or else nothing else will work
		light(user)
		return
	if(on_fire && (istype(W, /obj/item/flame) || istype(W, /obj/item/device/flashlight/flare/torch) || istype(W, /obj/item/clothing/mask/smokable))) //light unlit stuff
		W.attackby(src, user)
		return
	if(fuel < max_fuel)
		if(istype(W, /obj/item/stack/material))
			var/obj/item/stack/material/I = W
			if(I.default_type in burnable_materials)
				I.use(1)
				fuel = min(fuel + burnable_materials[I.default_type], max_fuel)
				user.visible_message(SPAN_NOTICE("\The [user] adds some of \the [I] to \the [src]."))
				return
		if(is_type_in_list(W, burnable_other))
			var/fuel_add = burnable_other[W]
			fuel = min(fuel + fuel_add, max_fuel)
			user.visible_message(SPAN_NOTICE("\The [user] tosses \the [W] into \the [src]."))
			user.drop_from_inventory(W)
			qdel(W)
			return
		else if(istype(W, /obj/item/material))
			var/obj/item/material/M = W
			if(M.material.name in burnable_materials)
				var/fuel_add = burnable_materials[M.material] * (M.w_class / 5) //if you crafted a small item, it's not worth as much fuel
				fuel = min(fuel + fuel_add, max_fuel)
				user.visible_message(SPAN_NOTICE("\The [user] tosses \the [M] into \the [src]."))
				user.drop_from_inventory(W)
				W.forceMove(get_turf(src))
				qdel(W)
				return
	if(istype(W, /obj/item/reagent_containers))
		if(istype(W, /obj/item/reagent_containers/cooking_container/fire))
			cook_machine.attackby(W, user)
		else
			var/obj/item/reagent_containers/RC = W
			if(RC.is_open_container())
				RC.reagents.trans_to(src, RC.amount_per_transfer_from_this)
				handle_reagents()

/obj/structure/bonfire/proc/light(mob/user)
	if(!fuel)
		to_chat(user, SPAN_WARNING("There is not enough fuel to start a fire."))
		return
	if(total_active_bonfires.len >= MAX_ACTIVE_BONFIRE_LIMIT)
		to_chat(user, SPAN_WARNING("\The [src] refuses to light, despite all your efforts."))
		return
	if(!on_fire)
		on_fire = TRUE
		check_light()
		update_icon()
		START_PROCESSING(SSprocessing, src)
		total_active_bonfires += src
	if(!cook_machine)
		cook_machine = new () // we don't want one before it's lit, to save memory and junk
		cook_machine.stat = 0 // since, presumably, it's on fire now
		cook_machine.cooking_power = 0.75

/obj/structure/bonfire/proc/check_light()
	if(on_fire)
		switch(fuel)
			if(0 to 200)
				set_light(2)
			if(200 to 600)
				set_light(3)
			if(600 to 900)
				set_light(4)
			if(900 to 1300)
				set_light(5)
			if(1300 to 2000)
				set_light(6)
	else
		set_light(0)

/obj/structure/bonfire/proc/check_heat_range()
	if(on_fire)
		switch(fuel)
			if(0 to 200)
				heat_range = 2
			if(200 to 600)
				heat_range = 3
			if(600 to 900)
				heat_range = 4
			if(900 to 1300)
				heat_range = 5
			if(1300 to 2000)
				heat_range = 6
	else
		heat_range = 0
	return heat_range


/obj/structure/bonfire/proc/handle_reagents()
	if(reagents.total_volume > 0 && on_fire)
		for(var/datum/reagent/R in reagents.reagent_list)
			switch(R.id)
				if("fuel" || "woodpulp")
					fuel = min(max_fuel, fuel + R.volume * 5)
				if("water")
					fuel = max(0, fuel - R.volume * 10)
				if("monoammoniumphosphate")
					fuel = max(0, fuel - R.volume * 20)
				if("phoron") //Why. Copied from scrubber event
					fuel = min(max_fuel, fuel + (R.volume * 25))

			if(istype(R, /datum/reagent/alcohol))
				var/datum/reagent/alcohol/A = R
				fuel = min(max_fuel, fuel + (R.volume * (A.strength/20)))
			R.remove_self(R.volume)


/obj/structure/bonfire/process()
	if(!on_fire)
		return

	handle_reagents()

	fuel -= rand(1, 2)

	if(fuel <= 0)
		extinguish()
		playsound()

	update_icon()

	if(isturf(loc))
		var/turf/T = loc
		T.hotspot_expose(700, 5)

	if(locate(/mob/living, src.loc))
		var/mob/living/M = locate(/mob/living, src.loc)
		burn(M)

	check_light()
	heat()
	warm_person()
	if(prob(2))
		ambient_message()
	playsound(get_turf(src), 'sound/waystation/fireplace.ogg', 30, 1, -3)

/obj/structure/bonfire/proc/extinguish()
	on_fire = FALSE
	STOP_PROCESSING(SSprocessing, src)
	check_light()
	update_icon()
	total_active_bonfires -= src
	if(cook_machine)
		cook_machine.stat |= POWEROFF
	if(burn_out)
		visible_message(SPAN_NOTICE("\The [src] burns out, turning to a pile of ash and burnt wood."))
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)

/obj/structure/bonfire/proc/heat()
	if(!on_fire)
		return
	heating_power = 32000 * (fuel / max_fuel)	//Less fuel, less heat
	var/turf/simulated/L = get_turf(src)
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()
		if(env && abs(env.temperature - (T20C + 5)) > 0.1)
			var/transfer_moles = 0.35 * env.total_moles
			var/datum/gas_mixture/removed = env.remove(transfer_moles)

			if(removed)
				var/heat_transfer = removed.get_thermal_energy_change(T20C + 5)
				if(heat_transfer > 0)	//heating air
					heat_transfer = min(heat_transfer, heating_power)
					removed.add_thermal_energy(heat_transfer)
				env.merge(removed)
	//fire_act stuff inside. Mobs handled in burn()
	for(var/obj/O in get_turf(src))
		if(O == src)
			continue
		heat_object(O)

/obj/structure/bonfire/proc/heat_object(obj/O)
	if(istype(O, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = O
		var/current_temperature = RC.reagents.get_temperature()
		if(current_temperature <= 310)
			var/thermal_energy_limit = RC.reagents.get_thermal_energy_change(current_temperature, 310) 
			RC.reagents.add_thermal_energy(min(1750, thermal_energy_limit))
			RC.reagents.handle_reactions()

	if(istype(O, /obj/item/stack/material))
		var/obj/item/stack/material/I = O
		if(I.default_type in burnable_materials)
			if(max_fuel - fuel >= burnable_materials[I.default_type])
				I.use(1)
				fuel += burnable_materials[I.default_type] * 0.75
	O.fire_act()

/obj/structure/bonfire/proc/warm_person()
	if(!on_fire)
		return
	heat_range = check_heat_range()
	var/turf/simulated/L = get_turf(src)
	if(!istype(L))
		return

	for(var/mob/living/carbon/human/H in oview(src, heat_range))
		var/turf/simulated/T = get_turf(H)
		var/datum/gas_mixture/mob_env
		if(!istype(T))
			continue
		mob_env = T.return_air()

		var/temp_adj = max(min(T20C, mob_env.temperature) - H.bodytemperature, -8)
		if(temp_adj > -1)	//only heats, not precise
			continue
		var/distance = get_dist(src, H)
		var/heating_div = distance > 2 ? distance - 1 : 1 //Heat drops off if you're 3 or more tiles away
		var/heat_eff = fuel / max_fuel	//Less fuel, less heat provided
		H.bodytemperature = min(H.bodytemperature + (abs((temp_adj * heat_eff)) / heating_div), 311)

/obj/structure/bonfire/Crossed(AM as mob|obj)
	if(on_fire)
		burn(AM, TRUE)
	..()

/obj/structure/bonfire/proc/burn(var/mob/living/M, var/entered = FALSE)
	if(safe)
		return
	if(M && prob((fuel / max_fuel) * 100))
		if(entered)
			to_chat(M, "<span class='warning'>You are covered by fire and heat from entering \the [src]!</span>")
		if(isanimal(M))
			var/mob/living/simple_animal/H = M
			if(H.flying) //flying mobs will ignore the lava
				return
			else
				M.bodytemperature = min(M.bodytemperature + 150, 1000)
		else
			if(prob(50))
				M.adjust_fire_stacks(5)
				M.IgniteMob()
				return

/obj/structure/bonfire/proc/ambient_message()
	if(on_fire && world.time >= last_ambient_message + 600)
		var/list/message_picks = list("The wood crackles in the heat.", "The flames of the fire dance vibrantly.", "Some wood crackles, sending harmless sparks dancing in the air",
				"The light of the fire pulses calmly.", "Dozens of sparks dance upward before burning out.")
		if(fuel / max_fuel >= 0.5)
			message_picks += list("The fire roars steadily.", "The flames flare up briefly, before relaxing once more.", "Light smoke twirls upward before fading away.")
		if(fuel / max_fuel <= 0.25)
			message_picks += list("The embers shift as a piece of wood falls into them.", "The glow of the fire pulses weakly.", "Ash dances upward with a few sparks.")
		var/message = "<I>[pick(message_picks)]</I>"
		visible_message(SPAN_GOOD(message))
		last_ambient_message = world.time

/obj/structure/bonfire/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/waystation/fireplace.dmi'
	icon_state = "fireplace_material"
	pixel_x = -16
	safe = TRUE
	density = TRUE
	burn_out = FALSE

/obj/structure/bonfire/fireplace/New(var/newloc, var/material_name)
	..()
	fuel = 0	//don't start with fuel
	if(!material_name)
		material_name = MATERIAL_MARBLE
	material = SSmaterials.get_material_by_name(material_name)
	if(!material)
		qdel(src)
		return
	name = "[material.display_name] fireplace"
	color = material.icon_colour

/obj/structure/bonfire/fireplace/update_icon()
	cut_overlays()
	if(on_fire)
		switch(fuel)
			if(0 to 250)
				add_overlay("fireplace_fire0")
			if(251 to 750)
				add_overlay("fireplace_fire1")
			if(751 to 1200)
				add_overlay("fireplace_fire2")
			if(1201 to 1700)
				add_overlay("fireplace_fire3")
			if(1700 to 2000)
				add_overlay("fireplace_fire4")
		add_overlay("fireplace_glow")

/obj/structure/bonfire/fireplace/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!istype(mover) || mover.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(loc, target) == NORTH)
		return !density
	return TRUE

/obj/structure/bonfire/fireplace/CheckExit(atom/movable/O, turf/target)
	if(get_dir(loc, target) == NORTH)
		return !density
	return TRUE



/////////////
// COOKING //
/////////////

/obj/item/reagent_containers/cooking_container/fire/
	var/appliancetype

/obj/item/reagent_containers/cooking_container/fire/pot
	name = "pot"
	shortname = "pot"
	desc = "Chuck ingredients in this to cook something over a fire."
	icon = 'icons/obj/food.dmi'
	icon_state = "stew_empty"
	w_class = ITEMSIZE_NORMAL
	appliancetype = POT


/obj/item/reagent_containers/cooking_container/fire/pot/New(var/newloc, var/mat_key)
	..(newloc)
	var/material/material = SSmaterials.get_material_by_name(mat_key ? mat_key : "iron")
	name = "[material.display_name] [initial(name)]"

/obj/item/reagent_containers/cooking_container/fire/oven
	name = "campfire oven"
	shortname = "oven"
	desc = "Chuck ingredients in this to bake something over a fire."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "dutchoven"
	w_class = ITEMSIZE_LARGE
	appliancetype = OVEN
	volume = 240


/obj/item/reagent_containers/cooking_container/fire/oven/New(var/newloc, var/mat_key)
	..(newloc)
	var/material/material = SSmaterials.get_material_by_name(mat_key ? mat_key : "iron")
	name = "[material.display_name] [initial(name)]"

/obj/item/reagent_containers/cooking_container/fire/skewer
	name = "wooden skewer"
	shortname = "skewer"
	desc = "Not a kebab."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "rods"
	appliancetype = SKEWER

/obj/item/material/shaft/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/cooking_container/fire/skewer/S = new ()
		if (!user || !user.put_in_hands(S))
			S.forceMove(get_turf(user ? user : src))
		qdel(src)
		S.attackby(I, user)

/obj/item/reagent_containers/cooking_container/fire/skewer/do_empty(mob/user)
	. = ..()
	if(!contents.len)
		var/obj/item/material/shaft/S = new ()
		if (!user || !user.put_in_hands(S))
			S.forceMove(get_turf(user ? user : src))
		qdel(src)

/obj/machinery/appliance/bonfire
	name = "bonfire"
	desc = "Nice and hot."
	cook_type = "roasted"
	appliancetype = 0 // depends on the cooking utensil used
	food_color = "#A34719"
	can_burn_food = 1
	use_power = 0
	component_types = list()

	mobdamagetype = BURN
	cooking_power = 0.75
	max_contents = 5
	container_type = /obj/item/reagent_containers/cooking_container/fire

/obj/machinery/appliance/bonfire/Initialize()
	. = ..()
	verbs -= .verb/toggle_power

/obj/machinery/appliance/bonfire/can_remove_items(var/mob/user)
	if(isanimal(user))
		return 0
	if(user in view(1))
		return 1

/obj/machinery/appliance/bonfire/list_contents(var/mob/user) //we don't want the "It is empty" message
	if(cooking_objs.len)
		var/string = "Contains..."
		for (var/a in cooking_objs)
			var/datum/cooking_item/CI = a
			string += "-\a [CI.container.label(null, CI.combine_target)], [report_progress(CI)]</br>"
		to_chat(user, string)

/obj/machinery/appliance/bonfire/attempt_toggle_power()
	return // just in case

/obj/machinery/appliance/bonfire/AICtrlClick() // i don't even know how but might as well
	return

/obj/machinery/appliance/bonfire/finish_cooking(var/datum/cooking_item/CI)
	//Check recipes first, a valid recipe overrides other options
	var/datum/recipe/recipe = null
	var/atom/C = null
	if (CI.container)
		C = CI.container
	if(!istype(CI.container, /obj/item/reagent_containers/cooking_container/fire))
		return
	var/obj/item/reagent_containers/cooking_container/fire/F = CI.container
	if(F.appliancetype)
		recipe = select_recipe(RECIPE_LIST(F.appliancetype), C)
	if (recipe)
		CI.result_type = 4//Recipe type, a specific recipe will transform the ingredients into a new food
		var/list/results = recipe.make_food(C)

		var/obj/temp = new /obj(src) //To prevent infinite loops, all results will be moved into a temporary location so they're not considered as inputs for other recipes

		for (var/atom/movable/AM in results)
			AM.forceMove(temp)

		//making multiple copies of a recipe from one container. For example, tons of fries
		while (select_recipe(RECIPE_LIST(F.appliancetype), C) == recipe)
			var/list/TR = list()
			TR += recipe.make_food(C)
			for (var/atom/movable/AM in TR) //Move results to buffer
				AM.forceMove(temp)
			results += TR

		for (var/r in results)
			var/obj/item/reagent_containers/food/snacks/R = r
			R.forceMove(C) //Move everything from the buffer back to the container
			R.cooked |= cook_type

		QDEL_NULL(temp) //delete buffer object
		. = 1 //None of the rest of this function is relevant for recipe cooking

	else
		//Otherwise, we're just doing standard modification cooking. change a color + name
		for (var/obj/item/i in CI.container)
			modify_cook(i, CI)

	//Final step. Cook function just cooks batter for now.
	for (var/obj/item/reagent_containers/food/snacks/S in CI.container)
		S.cook()

/obj/structure/bonfire/fireplace/stove
	name = "stove"
	desc = "A potbelly stove. Now it really feels like the frontier."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "stoveopen"
	pixel_x = 0
	safe = TRUE
	density = TRUE

/obj/structure/bonfire/fireplace/stove/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return FALSE

/obj/structure/bonfire/fireplace/stove/attackby(obj/item/I, mob/user)
	if(I.iswrench())
		if(on_fire)
			to_chat(user, SPAN_WARNING("You can't move \the [src] while it's burning."))
		else
			anchored = !anchored
			playsound(get_turf(src), I.usesound, 50, 1)
			var/message = "\The [user] [anchored ? "secures" : "unsecures"] \the [src] to the floor."
			visible_message(SPAN_NOTICE(message))
		return
	else
		..()

/obj/structure/bonfire/fireplace/stove/update_icon()
	cut_overlays()
	if(on_fire)
		switch(fuel)
			if(1 to 500)
				add_overlay("stove_fire0")
			if(500 to 1000)
				add_overlay("stove_fire1")
			if(1000 to 1500)
				add_overlay("stove_fire2")
			if(1500 to 1700)
				add_overlay("stove_fire3")
			if(1700 to 2000)
				add_overlay("stove_fire4")
		add_overlay("stove_glow")
	else if(fuel >= 1)
		icon_state = "stoveclosed_off"

	if(fuel == 0)
		icon_state = "stoveopen"

/obj/structure/bonfire/fireplace/oven
	name = "old iron oven"
	desc = "An oven."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "ovenopen"
	pixel_x = 0
	safe = TRUE
	density = 1

/obj/structure/bonfire/fireplace/oven/update_icon()
	cut_overlays()
	if(on_fire)
		switch(fuel)
			if(1 to 2000)
				icon_state = "ovenclosed_on"
	else if(fuel >= 1)
		icon_state = "ovenclosed_off"

	if(fuel == 0)
		icon_state = "ovenopen" 

/obj/structure/bonfire/fireplace/oven/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return FALSE

#undef MAX_ACTIVE_BONFIRE_LIMIT