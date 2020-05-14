/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red standard-issue flare. There are instructions on the side reading 'pull cord, make light'."
	w_class = 2.0
	brightness_on = 4 // Pretty bright.
	light_power = 4
	light_color = LIGHT_COLOR_FLARE //"#E58775"
	icon_state = "flare"
	item_state = "flare"
	action_button_name = null //just pull it manually, neckbeard.
	var/fuel = 0
	uv_intensity = 100
	var/on_damage = 7
	var/produce_heat = 1500
	light_wedge = LIGHT_OMNI
	activation_sound = 'sound/items/flare.ogg'
	drop_sound = 'sound/items/drop/gloves.ogg'

/obj/item/device/flashlight/flare/Initialize()
	. = ..()
	fuel = rand(400, 500) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			src.icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSprocessing, src)

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	src.force = initial(src.force)
	src.damtype = initial(src.damtype)
	update_icon()

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message(
		"<span class='notice'>[user] activates the flare.</span>",
		"<span class='notice'>You pull the cord on the flare, activating it!</span>"
		)
		src.force = on_damage
		src.damtype = "fire"
		START_PROCESSING(SSprocessing, src)

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "An old school torch."
	brightness_on = 2
	light_power = 2
	light_color = LIGHT_COLOR_FIRE //"#E58775"
	icon = 'icons/waystation/weapons.dmi'
	icon_state = "torch"
	item_state = "torch"
	contained_sprite = TRUE
	uv_intensity = 50
	produce_heat = 1200


/obj/item/device/flashlight/flare/torch/Initialize()
	. = ..()
	fuel = rand(300, 450) 

/obj/item/device/flashlight/flare/torch/attack_self(mob/user)
	return

/obj/item/device/flashlight/flare/torch/update_icon()
	..()
	if(ismob(src.loc))	//for reasons, this makes torches work.
		item_state = icon_state
		var/mob/M = src.loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/device/flashlight/flare/torch/proc/light(mob/user)
	user.visible_message(SPAN_NOTICE("\The [user] lights \the [src]."),
						SPAN_NOTICE("You light \the [src]."))
	force = on_damage
	damtype = "fire"
	START_PROCESSING(SSprocessing, src)
	on = TRUE
	update_icon()

/obj/item/device/flashlight/flare/torch/attackby(var/obj/item/I, mob/user)
	if(!on && isflamesource(I))
		light(user)
	else
		..()

/obj/item/device/flashlight/flare/torch/shitty
	name = "flaming stick"
	desc = "How exciting!"
	brightness_on = 1.5
	light_power = 1
	produce_heat = 400

/obj/item/device/flashlight/flare/torch/shitty/Initialize()
	. = ..()
	fuel = rand(30, 45)
	on = TRUE
	START_PROCESSING(SSprocessing, src)
	update_icon()

/obj/item/device/flashlight/flare/torch/shitty/turn_off()
	visible_message("\The [src] burns out.")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/torch_handle
	name = "torch handle"
	desc = "An old-school torch handle. Not exactly useful without a head."
	w_class = ITEMSIZE_SMALL
	icon = 'icons/waystation/weapons.dmi'
	icon_state = "torch-empty"
	item_state = "torch-empty"
	contained_sprite = TRUE

/obj/item/torch_handle/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/torch_head))
		to_chat(user, SPAN_NOTICE("You attach \the [I] to \the [src]."))
		var/obj/item/device/flashlight/flare/torch/torch = new()
		qdel(I)
		qdel(src)
		user.put_in_hands(torch)

/obj/item/torch_head
	name = "torch head"
	desc = "A bit of cloth treated with wax."
	icon = 'icons/waystation/weapons.dmi'
	icon_state = "torch_head"
	w_class = ITEMSIZE_SMALL
	