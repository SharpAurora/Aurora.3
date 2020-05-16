//////////////////////////////
//Crafting using tools, such as chisels, knives, etc.
//////////////////////////////
#define BLOCK_CUT_POOR 1
#define BLOCK_CUT_AVG 2
#define BLOCK_CUT_GOOD 3

/obj/item/proc/can_craft(obj/O)
	var/material/material = O.get_material()
	if(material?.craft_type && (material.craft_type in crafting_precision))
		return crafting_precision[material.craft_type]
	return FALSE

//recipes for when we use a tool on an item
/obj/item/stack/material/proc/get_craft_chunk(mob/user, var/precision)
	use(1)
	visible_message(SPAN_NOTICE("\The [user] splits off a piece of \the [src]."))

	var/obj/item/material/crafting_block/B
	if(material.craft_type == CRAFTING_FABRIC)
		B = new /obj/item/material/crafting_block/fabric(get_turf(user), material.name)
	if(material.name == MATERIAL_WOOD_BRANCH)
		B = new /obj/item/material/crafting_block/branch(get_turf(user), material.name)
	else
		B = new /obj/item/material/crafting_block(get_turf(user), material.name)

	if(precision <= 4)
		if(prob(precision * 10))
			B.cut_quality = BLOCK_CUT_AVG
		else
			B.cut_quality = BLOCK_CUT_POOR
	else
		if(prob(precision * 10))
			B.cut_quality = BLOCK_CUT_GOOD
		else
			B.cut_quality = BLOCK_CUT_AVG

//crafting block
/obj/item/material/crafting_block
	name = "crafting block"
	desc = "A small selection of some material, used for precision crafting."
	w_class = ITEMSIZE_NORMAL
	icon = 'icons/obj/stacks/materials.dmi'
	icon_state = "crafting_block"
	default_material = MATERIAL_WOOD
	var/being_crafted
	var/cut_quality //Quality of the cut, by defines. A hidden value. Affects craftsmanship at the end.

/obj/item/material/crafting_block/fabric
	name = "crafting swatch"
	icon_state = "crafting_block_fabric"
	default_material = MATERIAL_CLOTH

/obj/item/material/crafting_block/branch
	name = "crafting stick"
	desc = "A cleaned-up branch, ready to be carved."
	icon_state = "crafting_block_branch"
	default_material = MATERIAL_WOOD_BRANCH
	w_class = ITEMSIZE_SMALL


/obj/item/material/crafting_block/attackby(obj/item/I, mob/user)
	var/precision = I.can_craft(src)
	if(precision && ishuman(user))
		if(!isturf(loc) && loc != user)
			return
		if(being_crafted)
			return
		create(I, user, precision)
		return
	..()

/obj/item/material/crafting_block/proc/create(obj/item/I, mob/user, var/precision)
	var/list/crafting_list = material.tool_recipes
	var/datum/crafting_item/craft = input(user, "What would you like to create?") as null|anything in crafting_list
	if(!craft)
		return
	being_crafted = TRUE
	user.visible_message(SPAN_NOTICE("\The [user] begins creating something from \the [src]..."),
					SPAN_NOTICE("You begin creating a [craft]."))
	var/time_to_craft = precision >= 7 ? 60 : 40
	if(do_after(user, time_to_craft * precision))
		if(!Adjacent(user) || (loc != user && !isturf(loc))) //Gotta still be close
			world << "Not adjacent, not on user, not on turf"
			return
		if(istype(I, /obj/item/device/autoshaper))
			var/obj/item/device/autoshaper/A = I
			if(!A.cell.checked_use(A.power_use))
				to_chat(user, SPAN_NOTICE("\The [A] ran out of power before you could finish..."))
				A.cell.use(A.cell.charge)
				return
		var/c_name = sanitize(input("What would you like to name the [craft]? Remember to use lowercase unless it's a proper noun. (Cancel for Default)") as text|null, MAX_LNAME_LEN)
		var/c_desc = sanitize(input("Would you like to describe the [craft] in more detail? Don't forget punctuation. (Cancel for Default)") as text|null)
		var/obj/item/created_item = craft.create(user)
		created_item.add_fingerprint(user)
		if(c_name)
			created_item.name = c_name
		if(c_desc)
			created_item.desc = c_desc
		set_craftsmanship(created_item, precision)
		user.drop_from_inventory(src)
		user.put_in_hands(created_item)
		qdel(src)
	else
		being_crafted = FALSE

/obj/item/material/crafting_block/proc/set_craftsmanship(var/obj/item/I, var/precision)
	var/craftsmanship
	//calc looks stupid complex but it comes out to this:
	//First, we check the tool's precision for the base range. Then we check the cut quality. Good cuts don't give a malus. Worse cuts give bigger penalties, slightly randomized.
	switch(max(0, rand(precision * 2, precision * 10) - ((3 - cut_quality) * rand(5, 15))))
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
	I.quality_desc = "The craftsmanship [craftsmanship]"

//Better tools
//Woodcarving
/obj/item/material/knife/woodcarving
	name = "woodcarving knife"
	desc = "A knife made with precision woodcarving in mind."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bayonet"
	force_divisor = 0.1 //Shitty as a weapon
	matter = list(DEFAULT_WALL_MATERIAL = 8000)
	use_material_name = FALSE
	crafting_precision = list(CRAFTING_WOOD = 7, CRAFTING_FABRIC = 2)

/obj/item/material/knife/woodcarving/artisan
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

/obj/item/chisel/artisan
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

/obj/item/fabric_tool/artisan
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

/obj/item/thermal_chisel/artisan
	name = "precision thermal chisel"
	icon_state = "firing_pin_pindi"
	crafting_precision = list(CRAFTING_METAL_SOFT = 10, CRAFTING_METAL_HARD = 9, CRAFTING_STONE = 4)

//Advanced
/obj/item/device/autoshaper
	name = "autoshaper"
	desc = "A handheld workshop, designed to work with extremely hard or brittle materials. Features a mini diamond-edged saw, thermal engraving tool, and rapid heater."
	icon = 'icons/obj/items.dmi'
	icon_state = "integrateddrill"
	w_class = ITEMSIZE_NORMAL
	var/obj/item/cell/cell
	var/power_use = 100 //how much charge we use
	var/panel_open
	crafting_precision = list(CRAFTING_HIGH_STRENGTH = 7, CRAFTING_METAL_HARD = 7)

/obj/item/device/autoshaper/artisan
	name = "artisan autoshaper"
	desc = "An advanced handheld workshop, designed to work with extremely hard or brittle materials. Features a mini diamond-edged saw, thermal engraving tool, and rapid heater."
	icon = 'icons/obj/device.dmi'
	icon_state = "pin_extractor-on"
	power_use = 250 
	crafting_precision = list(CRAFTING_HIGH_STRENGTH = 10, CRAFTING_METAL_HARD = 10)

/obj/item/device/autoshaper/Initialize()
	. = ..()
	cell = new /obj/item/cell/device(src)

/obj/item/device/autoshaper/Destroy()
	cell = null
	. = ..()

/obj/item/device/autoshaper/attackby(obj/item/I, mob/user)
	if(I.isscrewdriver())
		panel_open = !panel_open
		playsound(get_turf(user), I.usesound, 50, 1)
		var/open= panel_open ? "open" : "close"
		to_chat(user, SPAN_NOTICE("You [open] the panel of \the [src]."))
		return
	if(istype(I, /obj/item/cell))
		var/obj/item/cell/C = I
		if(!panel_open)
			to_chat(user, SPAN_NOTICE("Try opening the cell panel first."))
			return
		if(cell)
			to_chat(user, SPAN_NOTICE("There's already a power source installed."))
			return
		else
			if(!istype(C, /obj/item/cell/device) && !istype(C, /obj/item/cell/crap))
				to_chat(user, SPAN_NOTICE("This cell is too large."))
				return				
			else
				to_chat(user, SPAN_NOTICE("You install \the [C] in \the [src]."))
				user.drop_from_inventory(C, src)
				cell = C
				C.add_fingerprint(user)
				return
	..()

/obj/item/device/autoshaper/attack_hand(mob/user)
	if(panel_open && cell)
		to_chat(user, SPAN_NOTICE("You remove \the [cell] from \the [src]."))
		cell.forceMove(get_turf(user))
		user.put_in_hands(cell)
		cell = null
		return
	..()