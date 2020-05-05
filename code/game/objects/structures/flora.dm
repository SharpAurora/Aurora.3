//trees
/obj/structure/flora
	var/engraving	//if this has an engraving
	var/cutting

/obj/structure/flora/proc/do_engrave(var/obj/item/I, mob/user)
	if(engraving)
		to_chat(user, SPAN_NOTICE("There's already an engraving."))
		return
	else
		var/msg = sanitizeSafe(input("What would you like to carve into \the [src]?", "Message", ""), MAX_LNAME_LEN * 2)
		if(!msg)
			return
		else
			user.visible_message(SPAN_NOTICE("\The [user] carves something into \the [src] with \the [I]."),
							SPAN_NOTICE("You carve your message into \the [src]."))
			engraving = msg
			return

/obj/structure/flora/examine(mob/user)
	if(..(user, 1))
		if(engraving)
			to_chat(user, "A message is engraved into \the [src]: <I>[engraving]</I>")

/obj/structure/flora/proc/dig_up(mob/user)
	user.visible_message(SPAN_NOTICE("\The [user] begins digging up \the [src]..."))
	if(do_after(user, 150))
		if(Adjacent(user))
			user.visible_message(SPAN_NOTICE("\The [user] removes \the [src]!"))
			qdel(src)

/obj/structure/flora/tree
	name = "tree"
	desc = "A big ol' tree."
	anchored = TRUE
	density = TRUE
	pixel_x = -16
	layer = 9
	var/max_chop_health = 180
	var/chop_health = 180 //15 hits with steel hatchet, 5 with wielded fireaxe
	var/fall_force = 60
	var/list/contained_objects = list()	//If it has anything except wood. Fruit, pinecones, animals, etc.
	var/stumptype = /obj/structure/flora/stump //stump to make when chopped
	var/static/list/fall_forbid = list(/obj/structure/flora, /obj/effect, /obj/structure/bonfire, /obj/structure/pit) //things we don't want a crush message for

/obj/structure/flora/tree/proc/update_desc()
	desc = initial(desc)
	switch(chop_health / max_chop_health)
		if(0 to 0.25)
			desc = " It looks like it's about to fall!"
		if(0.26 to 0.5)
			desc += " Just a bit more work and it'll fall!"
		if(0.51 to 0.75)
			desc += " It's been chopped at a few times."
		if(0.76 to 0.95)
			desc += " Looks like someone just started cutting it down."

/obj/structure/flora/tree/attackby(obj/item/I, mob/user)
	if(I.can_woodcut())
		if(cutting)
			return
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		cutting = TRUE
		if(istype(I, /obj/item/material/twohanded/chainsaw))
			var/obj/item/material/twohanded/chainsaw/C = I
			if(C.powered)
				user.visible_message(SPAN_NOTICE("\The [user] begins cutting down \the [src]..."), SPAN_NOTICE("You start cutting down \the [src]..."))
				playsound(get_turf(user), 'sound/weapons/saw/chainsawhit.ogg', 60, 1)
				animate_shake()
				if(do_after(user, 50))
					timber(user)
			else
				to_chat(user, SPAN_WARNING("Try turning \the [C] on first!"))
				cutting = FALSE
				return
		else if(do_after(user, I.w_class * 5)) //Small windup
			user.do_attack_animation(src)
			animate_shake()
			playsound(get_turf(src), 'sound/effects/woodcutting.ogg', 50, 1)
			chop_health -= I.force
			update_desc()
			if(prob(20))
				user.visible_message(SPAN_NOTICE("\The [user] chops at \the [src]."), SPAN_NOTICE("You chop at \the [src]."), SPAN_NOTICE("You hear someone chopping wood."))
			if(prob(I.force/3))
				var/list/valid_turfs = list()
				for(var/turf/T in circlerange(src, 1))
					if(T.contains_dense_objects())
						continue
					valid_turfs += T
				if(!valid_turfs.len)
					valid_turfs += get_turf(src)
				var/obj/item/stack/material/wood/branch/B = new(pick(valid_turfs))
				B.amount = 1
				visible_message(SPAN_NOTICE("\The [B] falls from \the [src]."))

			if(chop_health <= 0)
				timber(user)
		cutting = FALSE
		return
	else if(I.sharp && user.a_intent != I_HURT)
		do_engrave(I, user)
		return
	..()

/obj/structure/flora/tree/proc/timber(mob/user)
	var/turf/fall_loc //Where we will fall

	//We prefer to fall directly away from the user if possible
	var/turf/pref_loc = get_cardinal_step_away(src, user)
	if(!pref_loc.contains_dense_objects(TRUE))
		fall_loc = pref_loc

	//Otherwise, we fall elsewhere
	else
		var/list/fall_spots = list()
		for(var/turf/T in orange(1, src))
			if(locate(user) in T.contents) //Won't fall on woodcutter
				continue
			if(T.contains_dense_objects(TRUE)) //Let's avoid dense objects but not mobs
				continue
			fall_spots += T

		if(!fall_spots.len)
			fall_loc = get_turf(src)
		else
			fall_loc = pick(fall_spots)
	playsound(get_turf(src), 'sound/species/diona/gestalt_grow.ogg', 50)
	for(var/atom/A in fall_loc.contents)
		if(is_type_in_list(A, fall_forbid))
			continue
		if(isliving(A))
			var/mob/living/L = A
			visible_message(SPAN_WARNING("\The [src] crushes \the [L] under its weight!"))
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				var/obj/item/organ/external/affected = pick(H.organs)
				affected.take_damage(fall_force)
			else
				if(L.mob_size <= fall_force / 5)
					L.gib()
				else
					L.health -= fall_force
					if(L.health <= 0)
						L.gib()
				
		if(isobj(A) && !istype(A, /obj/item/stack) && A != src)
			var/obj/O = A
			if(prob(fall_force * 0.75))
				visible_message(SPAN_WARNING("\The [src] crushes \the [O] under its weight!"))
				qdel(A)
	new /obj/structure/flora/stump/log(fall_loc)
	var/obj/item/stack/material/wood/branch/B = new(fall_loc)
	B.amount = rand(5, 8)
	new stumptype(get_turf(src))
	qdel(src)

/obj/structure/flora/stump
	name = "stump"
	desc = "Nature's chair."
	icon = 'icons/obj/woodrelated.dmi'
	icon_state = "tree_stump"
	density = FALSE
	anchored = TRUE

/obj/structure/flora/stump/attackby(obj/item/I, mob/user)
	if(I.sharp && user.a_intent != I_HURT)
		do_engrave(I, user)
		return
	if(istype(I, /obj/item/shovel))
		dig_up(user)
		return
	..()

/obj/structure/flora/stump/log
	name = "big log"
	desc = "A sideways tree, but dead. Chop this into useable logs!"
	anchored = FALSE
	icon_state = "timber"

/obj/structure/flora/stump/log/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/shovel)) //can't dig this up
		return
	if(I.can_woodcut())
		if(cutting)
			return
		cutting = TRUE
		var/chopsound = istype(I, /obj/item/material/twohanded/chainsaw) ? 'sound/weapons/saw/chainsawhit.ogg' : 'sound/effects/woodcutting.ogg'
		playsound(get_turf(user), chopsound, 50, 1)
		user.visible_message(SPAN_NOTICE("\The [user] begins chopping \the [src] into log sections."), SPAN_NOTICE("You begin chopping \the [src] into log sections."))
		var/chopspeed = 1
		if(istype(I, /obj/item/material/twohanded))
			var/obj/item/material/twohanded/W = I
			chopspeed = W.wielded ? 2 : 1
		if(do_after(user, 100 / chopspeed))
			user.visible_message(SPAN_NOTICE("\The [user] chops \the [src] into log sections."), SPAN_NOTICE("You chop \the [src] into log sections."))
			var/obj/item/stack/material/wood/log/L = new(get_turf(src))
			L.amount = rand(5, 8)
			qdel(src)
		cutting = FALSE
	else
		..()
	

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/New()
	..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/New()
	..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/New()
	..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/dead/memorial
	name = "engraved tree"
	desc = "A memorial to the fallen."
	engraving = "Here rests Shaitan. Your name was an omen, but you were a faithful and loving companion, taken too soon from this universe. You will be missed, by your master most of all."

/obj/structure/flora/tree/jungle
	name = "tree"
	icon_state = "tree"
	desc = "A lush and healthy tree."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

//rocks
/obj/structure/flora/rock
	icon_state = "basalt"
	desc = "A rock."
	icon = 'icons/obj/flora/rocks_grey.dmi'
	density = TRUE

/obj/structure/flora/rock/pile
	name = "rocks"
	icon_state = "lavarocks"
	desc = "A pile of rocks."

/obj/structure/flora
	name = "bush"
	gender = PLURAL
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowgrass1bb"
	anchored = TRUE

/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	mouse_opacity = 0

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/Initialize()
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"

//Jungle grass
/obj/structure/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa"

/obj/structure/flora/grass/jungle/b
	icon_state = "grassb"

//bushes
/obj/structure/flora/bush/snow
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"

/obj/structure/flora/bush/snow/Initialize()
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/plants.dmi'
	icon_state = "plant-26"
	var/dead = 0
	var/obj/item/stored_item

/obj/structure/flora/pottedplant/Destroy()
	QDEL_NULL(stored_item)
	return ..()

/obj/structure/flora/pottedplant/proc/death()
	if (!dead)
		icon_state = "plant-dead"
		name = "dead [name]"
		desc = "It looks dead."
		dead = 1
//No complex interactions, just make them fragile
/obj/structure/flora/pottedplant/ex_act(var/severity = 2.0)
	death()
	return ..()

/obj/structure/flora/pottedplant/fire_act()
	death()
	return ..()

/obj/structure/flora/pottedplant/attackby(obj/item/W, mob/user)
	if(!ishuman(user))
		return
	if(istype(W, /obj/item/holder))
		return //no hiding mobs in there
	user.visible_message("[user] begins digging around inside of \the [src].", "You begin digging around in \the [src], trying to hide \the [W].")
	playsound(loc, 'sound/effects/plantshake.ogg', 50, 1)
	if(do_after(user, 20, act_target = src))
		if(!stored_item)
			if(W.w_class <= ITEMSIZE_NORMAL)
				user.drop_from_inventory(W,src)
				stored_item = W
				to_chat(user,"<span class='notice'>You hide \the [W] in [src].</span>")
				return
			else
				to_chat(user,"<span class='notice'>\The [W] can't be hidden in [src], it's too big.</span>")
				return
		else
			to_chat(user,"<span class='notice'>There is something hidden in [src].</span>")
			return
	return ..()

/obj/structure/flora/pottedplant/attack_hand(mob/user)
	user.visible_message("[user] begins digging around inside of \the [src].", "You begin digging around in \the [src], searching it.")
	playsound(loc, 'sound/effects/plantshake.ogg', 50, 1)
	if(do_after(user, 40, act_target = src))
		if(!stored_item)
			to_chat(user,"<span class='notice'>There is nothing hidden in [src].</span>")
		else
			if(istype(stored_item, /obj/item/device/paicard))
				stored_item.forceMove(src.loc)
				to_chat(user,"<span class='notice'>You reveal \the [stored_item] from [src].</span>")
			else
				user.put_in_hands(stored_item)
				to_chat(user,"<span class='notice'>You take \the [stored_item] from [src].</span>")
			stored_item = null

/obj/structure/flora/pottedplant/bullet_act(var/obj/item/projectile/Proj)
	if (prob(Proj.damage*2))
		death()
		return 1
	return ..()

//Added random icon selection for potted plants.
//It was silly they always used the same sprite when we have 26 sprites of them in the icon file
/obj/structure/flora/pottedplant/random/New()
	..()
	var/number = rand(1,36)
	if (number == 36)
		if (prob(90))//Make the weird one rarer
			number = rand(1,35)
		else
			desc = "A half-sentient plant borne from a mishap in a Zeng-Hu genetics lab."

	switch(number) //Wezzy's cool new plant description code. Special thanks to Sindorman.
		if(3)
			desc = "A bouquet of Bieselite flora."
		if(4)
			desc = "A bamboo plant. Used widely in Japanese crafts."
		if(5)
			desc = "Some kind of fern."
		if(7)
			desc = "A reedy plant mostly used for decoration in Skrell homes, admired for its luxuriant stalks."
		if(9)
			desc = "A fleshy cave dwelling plant with huge nodules for flowers."
		if(9)
			desc = "A scrubby cactus adapted to the Moghes deserts."
		if(13)
			desc = "A hardy succulent adapted to the Moghes deserts."
		if(14)
			desc = "That's a huge flower. Previously, the petals would be used in dyes for unathi garb. Now it's more of a decorative plant."
		if(15)
			desc = "A pitiful pot of stubby flowers."
		if(18)
			desc = "An orchid plant. As beautiful as it is delicate."
		if(19)
			desc = "A ropey, aquatic plant with crystaline flowers."
		if(20)
			desc = "A bioluminescent half-plant half-fungus hybrid. Said to come from Sedantis I."
		if(22)
			desc = "A cone shrub. Sadly doesn't come from Coney Island."
		if(26)
			desc = "A bulrush. Commonly referred to as cattail."
		if(27)
			desc = "A rose bush. Don't prick yourself."
		if(32)
			desc = "A woody shrub."
		if(33)
			desc = "A woody shrub. Seems to be in need of watering."
		if(34)
			desc = "A woody shrub. This one seems to be in bloom. It's just like one of my japanese animes."
		else
			desc = "Just your common, everyday houseplant."



	if (number < 10)
		number = "0[number]"
	icon_state = "plant-[number]"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1

/obj/structure/flora/ausbushes/New()
	..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W,/obj/item/material/scythe/sickle))
		if(prob(50))
			new /obj/item/stack/material/wood(get_turf(src), 2)
		if(prob(40))
			new /obj/item/stack/material/wood(get_turf(src), 4)
		if(prob(10))
			var/pickberry = pick(list(/obj/item/seeds/berryseed,/obj/item/seeds/blueberryseed))
			new /obj/item/stack/material/wood(get_turf(src), 4)
			new pickberry(get_turf(src), 4)
			to_chat(usr, "<span class='notice'>You find some seeds as you hack the bush away!</span>")
		to_chat(usr, "<span class='notice'>You slice at the bush!</span>")
		qdel(src)
		playsound(src.loc, 'sound/effects/woodcutting.ogg', 50, 1)

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/New()
	..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/New()
	..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/New()
	..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/New()
	..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/New()
	..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/New()
	..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/New()
	..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/New()
	..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/New()
	..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/New()
	..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/New()
	..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/New()
	..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/New()
	..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/New()
	..()
	icon_state = "fullgrass_[rand(1, 3)]"