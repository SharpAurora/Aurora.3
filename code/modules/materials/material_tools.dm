//Crafting using tools, such as chisels, knives, etc.


/obj/item/proc/can_craft(obj/O)
	world << "Checking if [src] can_craft [O]"
	var/material/material = O.get_material()
	world << "Material is [material]"
	if(material?.craft_type && (material.craft_type in crafting_precision))
		return crafting_precision[material.craft_type]
	world << "material craft type [material.craft_type] not found in crafting_precision"
	return FALSE

//recipes for when we use a tool on an item
/obj/item/stack/material/proc/get_craft_chunk(mob/user)
	world << "getting craft chunk"
	use(1)
	visible_message(SPAN_NOTICE("\The [user] splits off a chunk of \the [src]."))
	new /obj/item/material/crafting_block(get_turf(src), material)

/obj/item/material/crafting_block
	name = "crafting block"
	desc = "A small selection of some material, used for precision crafting."
	w_class = ITEMSIZE_SMALL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullorb"
	default_material = MATERIAL_WOOD


/obj/item/material/crafting_block/attackby(obj/item/I, mob/user)
	var/precision = I.can_craft(src)
	world << "precision is [precision] attackby"
	if(precision && ishuman(user) && isturf(loc))
		create(I, user, precision)
		return
	..()

/obj/item/material/crafting_block/proc/create(obj/item/I, mob/living/carbon/human/user, var/precision)
	var/list/crafting_list = material.tool_recipes
	world << "running create(). Precision of [precision]."
	var/craft = input(user, "What would you like to create?") as null|anything in crafting_list
	if(!craft)
		world << "No craft. Returning"
		return
	user.visible_message(SPAN_NOTICE("\The [user] begins creating something from \the [src]..."),
					SPAN_NOTICE("You begin creating a [craft]."))
	if(do_after(user, 50 * precision))
		if(!Adjacent(user) || (loc != user && !isturf(loc))) //Gotta still be close
			world << "Not adjacent, not on user, not on turf"
			return
		if(user.l_hand != I || user.r_hand != I) //Gotta be holding the tool
			world << "[I] not found"
			return
		
		var/obj/item/created_item = crafting_list[craft]
		if(!created_item)
			return
		new created_item(loc)
		var/c_name = sanitize(input("Would you like to name the [created_item]?") as text|null, MAX_LNAME_LEN)
		var/c_desc = sanitize(input("Would you like to describe the [created_item] in more detail?") as text|null)
		if(c_name)
			created_item.name = c_name
		if(c_desc)
			created_item.desc = c_desc
		var/craftsmanship
		world << "Precision range of [precision] times 2 to times ten"
		switch(rand(precision * 2, precision * 10))
			if(0 to 9)
				craftsmanship = "is extremely shoddy, with countless flaws."
			if(10 to 19)
				craftsmanship = "is poor, with several flaws."
			if(20 to 35)
				craftsmanship = "is of average quality, with one or two flaws."
			if(36 to 49)
				craftsmanship = "is rather good, with no flaws."
			if(50 to 75)
				craftsmanship = "is a beautiful example of professional quality work."
			if(76 to 99)
				craftsmanship = "is exquisite, clearly done with care by a master."
			else
				if(prob(10))
					craftsmanship = "is one-of-a-kind. Few people will ever come close to making something so perfect."
				else
					craftsmanship = "is exquisite; a perfect example of the highest quality work expected from a master."
		created_item.quality_desc = "The craftsmanship [craftsmanship]"
		qdel(src)

/obj/item/material/crafting_block/proc/produce_recipe(datum/stack_recipe/recipe, mob/user)
	var/obj/O
	if(recipe.use_material)
		O = new recipe.result_type(get_turf(user), recipe.use_material)
	else
		O = new recipe.result_type(get_turf(user))
	O.set_dir(user.dir)
	O.add_fingerprint(user)

	if(istype(O, /obj/item/storage)) //BubbleWrap - so newly formed boxes are empty
		for(var/obj/item/I in O)
			qdel(I)
	user.drop_from_inventory(src)
	user.put_in_hands(O)
	return O

//Better tools
//Woodcarving
/obj/item/material/knife/woodcarving
	name = "woodcarving knife"
	desc = "A knife made with precision woodcarving in mind."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bayonet"
	force_divisor = 0.1 
	matter = list(DEFAULT_WALL_MATERIAL = 8000)
	use_material_name = FALSE
	crafting_precision = list(CRAFTING_WOOD = 7, CRAFTING_FABRIC = 2)

/obj/item/material/knife/woodcarving/multi
	name = "woodcarving multiknife"
	desc = "A utility knife that contains multiple folding blades and tools for different precision woodcarving."
	icon = 'icons/obj/tools.dmi'
	icon_state = "combitool"
	crafting_precision = list(CRAFTING_WOOD = 10, CRAFTING_FABRIC = 2)

//Stone and soft metal crafting
/obj/item/chisel
	name = "chisel"
	desc = "A tool for precise stoneworking."
	icon = 'icons/obj/tools.dmi'
	icon_state = "legacyscrewdriver"
	sharp = TRUE
	w_class = ITEMSIZE_SMALL
	matter = list(DEFAULT_WALL_MATERIAL = 8000)
	crafting_precision = list(CRAFTING_STONE = 7, CRAFTING_METAL_SOFT = 5, CRAFTING_WOOD = 3)

/obj/item/chisel/fine
	name = "precision chisel"
	desc = "A tool with switchable heads for precise stoneworking."
	icon_state = "digitool-screwdriver"
	sharp = TRUE
	crafting_precision = list(CRAFTING_STONE = 10, CRAFTING_METAL_SOFT = 7, CRAFTING_WOOD = 3)

//Fabric working
/obj/item/fabric_tool
	name = "fabric multitool"
	desc = "A tailor's dream! It has multiple tools in one convenient handle, such as needles and thread, clippers, measuring tool, and more!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "combitool-wirecutters"
	sharp = TRUE
	w_class = ITEMSIZE_SMALL
	crafting_precision = list(CRAFTING_FABRIC = 8)

/obj/item/fabric_tool/auto
	name = "fabric autotool"
	desc = "A tailor's dream! It's like a handheld sewing machine, along with every other tool you might need for sewing!"
	icon_state = "digitool-wirecutters"
	crafting_precision = list(CRAFTING_FABRIC = 10)

//Metals
/obj/item/thermal_chisel
	name = "thermal chisel"
	desc = "A sharp tool for precision metalworking, with thermal precision control for engraving and heating metal, and a heavy steel handle for shaping it."
	icon = 'icons/obj/firingpins.dmi'
	icon_state = "firing_pin_red"
	sharp = TRUE
	w_class = ITEMSIZE_SMALL
	crafting_precision = list(CRAFTING_METAL_SOFT = 7, CRAFTING_METAL_HARD = 7, CRAFTING_STONE = 4)

/obj/item/thermal_chisel/fine
	name = "precision thermal chisel"
	icon_state = "firing_pin_pindi"
	crafting_precision = list(CRAFTING_METAL_SOFT = 10, CRAFTING_METAL_HARD = 9, CRAFTING_STONE = 4)