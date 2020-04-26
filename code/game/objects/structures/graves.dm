/obj/structure/pit
	name = "pit"
	desc = "Watch your step, partner."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "pit1"
	blend_mode = BLEND_MULTIPLY
	density = FALSE
	anchored = TRUE
	var/open = TRUE
	var/list/grave_types = list(MATERIAL_WOOD)

/obj/structure/pit/Destroy()
	for(var/A in src)
		qdel(A)
	. = ..()

/obj/structure/pit/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/shovel))
		visible_message(SPAN_NOTICE("\The [user] starts [open ? "filling" : "digging open"] \the [src]."))
		if(do_after(user, 50))
			visible_message(SPAN_NOTICE("\The [user] [open ? "fills" : "digs open"] \the [src]!"))
			if(open)
				close(user)
			else
				open()
		else
			to_chat(user, SPAN_NOTICE("You stop shoveling."))
		return
	if(!open && istype(W, /obj/item/stack/material))
		var/obj/item/stack/material/M = W
		if(locate(/obj/structure/gravemarker) in get_turf(src))
			to_chat(user, SPAN_NOTICE("There's already a grave marker here."))
		if(M.default_type in grave_types)
			visible_message(SPAN_NOTICE("\The [user] starts making a grave marker on top of \the [src]."))
			if(do_after(user, 100))
				visible_message(SPAN_NOTICE("\The [user] finishes the grave marker."))
				M.use(1)
				if(M.default_type == MATERIAL_WOOD)
					new /obj/structure/gravemarker(get_turf(src))
				//else if(M.default_type == MATERIAL_STONE)
				//	new /obj/structure/gravemarker/stone(get_turf(src)) ////////////////Uncomment when stone material is in
				for(var/mob/living/L in src.contents)
					if(L.stat == DEAD)
						SSjobs.DespawnMob(L)
			else
				to_chat(user, SPAN_NOTICE("You stop making a grave marker."))
		return
	..()

/obj/structure/pit/update_icon()
	icon_state = "pit[open]"
	if(istype(loc,/turf/simulated/floor))
		var/turf/simulated/floor/E = loc
		if(E.mudpit)
			icon_state="pit[open]mud"
			blend_mode = BLEND_OVERLAY

/obj/structure/pit/proc/open()
	name = "pit"
	desc = "Watch your step, partner."
	open = TRUE
	opacity = 0
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
	update_icon()

/obj/structure/pit/proc/close(var/user)
	name = "mound"
	desc = "Some things are better left buried."
	open = FALSE
	opacity = 1
	for(var/atom/movable/A in get_turf(src))
		if(!A.anchored && A != user)
			A.forceMove(src)
	update_icon()

/obj/structure/pit/return_air()
	return open

/obj/structure/pit/proc/digout(var/mob/escapee)
	var/breakout_time = 1 //2 minutes by default

	if(open)
		return

	if(escapee.stat || escapee.restrained())
		return

	escapee.setClickCooldown(100)
	to_chat(escapee, "<span class='warning'>You start digging your way out of \the [src] (this will take about [breakout_time] minute\s)</span>")
	visible_message("<span class='danger'>Something is scratching its way out of \the [src]!</span>")

	for(var/i in 1 to (6*breakout_time * 2)) //minutes * 6 * 5seconds * 2
		playsound(src.loc, 'sound/weapons/bite.ogg', 100, 1)

		if(!do_after(escapee, 50))
			to_chat(escapee, "<span class='warning'>You have stopped digging.</span>")
			return
		if(open)
			return

		if(i == 6*breakout_time)
			to_chat(escapee, "<span class='warning'>Halfway there...</span>")

	to_chat(escapee, "<span class='warning'>You successfuly dig yourself out!</span>")
	visible_message("<span class='danger'>\the [escapee] emerges from \the [src]!</span>")
	playsound(src.loc, 'sound/effects/squelch1.ogg', 100, 1)
	open()

/obj/structure/pit/Crossed(var/atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/M = AM
		if(open && prob(10) && !M.lying)
			visible_message(SPAN_WARNING("\The [M] stumbles over the open hole in the ground and falls!"))
			M.Weaken(1)
	..()

/obj/structure/pit/closed
	name = "mound"
	desc = "Some things are better left buried."
	open = FALSE
	opacity = 1

/obj/structure/pit/closed/Initialize()
	. = ..()
	close()

//invisible until unearthed first
/obj/structure/pit/closed/hidden
	invisibility = INVISIBILITY_OBSERVER

/obj/structure/pit/closed/hidden/open()
	..()
	invisibility = INVISIBILITY_LEVEL_ONE

//Graves, with coffins and human remains, for mapping
/obj/structure/pit/closed/grave
	name = "grave"
	icon_state = "pit0"

/obj/structure/pit/closed/grave/Initialize()
	. = ..()
	var/obj/structure/closet/coffin/C = new(src)
	var/obj/effect/decal/remains/human/bones = new(C)
	bones.layer = BELOW_MOB_LAYER


/obj/structure/gravemarker
	name = "grave marker"
	desc = "You're not the first."
	icon = 'icons/waystation/structures.dmi'
	icon_state = "wooden"
	pixel_x = 15
	pixel_y = 8
	anchored = 1
	var/message

	var/writing_tool = /obj/item/pen
	var/destroyed_stack = /obj/item/stack/material/wood

/obj/structure/gravemarker/examine()
	..()
	to_chat(usr,"It says: '[message]'")

/obj/structure/gravemarker/attackby(obj/item/W, mob/user)
	if(W.force >= 10)
		visible_message(SPAN_WARNING("\The [user] starts breaking down \the [src] with \the [W]."))
		if(!do_after(user, 80 - W.force))
			visible_message(SPAN_WARNING("\The [user] breaks \the [src] apart."))
			new destroyed_stack(get_turf(src))
			qdel(src)
	if(istype(W, writing_tool))
		var/prompt_text = message ? "What would you like to add? (Delete the previous message. What you write will be added on)" : "What should it say?"
		var/msg = sanitize(input(user, "[prompt_text]", "Grave marker", message) as text|null)
		if(!msg)
			return
		if(message)
			message += " [msg]"
		else
			message = msg 

/* UNCOMMENT WHEN STONE MATERIAL IS IN
/obj/structure/gravemarker/stone
	desc = "They won't be the last."
	icon_state = "stone"
	destroyed_stack = /obj/item/stack/material/stone/rock
*/