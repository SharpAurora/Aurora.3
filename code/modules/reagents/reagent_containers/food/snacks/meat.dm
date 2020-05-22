/obj/item/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	center_of_mass = list("x"=16, "y"=14)
	cooked_icon = "meatstake"
	slice_path = /obj/item/reagent_containers/food/snacks/rawcutlet
	slices_num = 3

/obj/item/reagent_containers/food/snacks/meat/Initialize()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("triglyceride", 2)
	src.bitesize = 1.5

/obj/item/reagent_containers/food/snacks/meat/cook()

	if (!isnull(cooked_icon))
		icon_state = cooked_icon
		flat_icon = null //Force regenating the flat icon for coatings, since we've changed the icon of the thing being coated
	..()

	if (name == initial(name))
		name = "cooked [name]"

/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

// TODO cancelled, subtypes are fine. recipes use istype checks
/obj/item/reagent_containers/food/snacks/meat/human

/obj/item/reagent_containers/food/snacks/meat/bug
	filling_color = "#E6E600"
/obj/item/reagent_containers/food/snacks/meat/bug/Initialize()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("phoron", 27)
	src.bitesize = 1.5

/obj/item/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "corgi meat"
	desc = "Tastes like... well, you know."

/obj/item/reagent_containers/food/snacks/meat/chicken
	name = "chicken meat"
	icon_state = "chickenbreast"
	cooked_icon = "chickenbreast_cooked"
	filling_color = "#BBBBAA"

/obj/item/reagent_containers/food/snacks/meat/samak
	name = "samak meat"
	desc = "A slab of lean samak meat."
	icon_state = "bearmeat"
	cooked_icon = "chickenbreast_cooked"

/obj/item/reagent_containers/food/snacks/meat/samak/Initialize()
	. = ..()
	reagents.add_reagent("protein", 2) //adds this to parent's initialization

/obj/item/reagent_containers/food/snacks/meat/shantak
	name = "shantak meat"
	desc = "A slab of shantak meat."
	icon_state = "adhomaimeat"

/obj/item/reagent_containers/food/snacks/meat/shantak/Initialize()
	. = ..()
	reagents.add_reagent("protein", 2)

/obj/item/reagent_containers/food/snacks/meat/diyaab
	name = "diyaab meat"
	desc = "A small slab of diyaab meat. You get used to the taste..."
	icon_state = "lizardmeat"
	filling_color = "#75b91b"
	cooked_icon = "grilled_carp_slice"
	slice_path = /obj/item/reagent_containers/food/snacks/rawcutlet
	slices_num = 2

/obj/item/reagent_containers/food/snacks/meat/diyaab/Initialize()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("protein", 2)
	reagents.add_reagent("virusfood", 2)
	src.bitesize = 1

/obj/item/reagent_containers/food/snacks/meat/skikja
	name = "skikja meat"
	desc = "A thin cut of skikja meat. So many little bones..."
	icon_state = "fishfillet"
	filling_color = "#456691"
	cooked_icon = "chickenbreast_cooked"
	slice_path = /obj/item/reagent_containers/food/snacks/rawcutlet
	slices_num = 2

/obj/item/reagent_containers/food/snacks/meat/skikja/Initialize()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("protein", 2)

/obj/item/reagent_containers/food/snacks/meat/wyvern
	name = "wyvern meat"
	desc = "A huge slab of meat."
	icon_state = "bearmeat"
	filling_color = "#660c0c"
	cooked_icon = "meatstake"
	slice_path = /obj/item/reagent_containers/food/snacks/rawcutlet
	slices_num = 5

/obj/item/reagent_containers/food/snacks/meat/wyvern/Initialize()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("triglyceride", 2)

/obj/item/reagent_containers/food/snacks/meat/biogenerated
	name = "bio meat"
	desc = "Did this come from the Biogenerator, or is it a biohazard? Perhaps it is both."
	icon_state = "plantmeat"
	filling_color = "#A8AA00"

/obj/item/reagent_containers/food/snacks/meat/biogenerated/Initialize()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment",6)

/obj/item/reagent_containers/food/snacks/meat/chicken/Initialize()
	. = ..()
	reagents.remove_reagent("triglyceride", INFINITY)
	//Chicken is low fat. Less total calories than other meats

/obj/item/reagent_containers/food/snacks/meat/undead
	name = "rotten meat"
	desc = "A slab of rotten meat."
	icon_state = "shadowmeat"

/obj/item/reagent_containers/food/snacks/meat/undead/Initialize()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("undead_ichor", 5)

/obj/item/reagent_containers/food/snacks/meat/adhomai
	name = "adhomian meat"
	desc = "A slab of an animal native from Adhomai."
	icon_state = "adhomai_meat"
	description_fluff = "For much of Tajaran history, the herbivorous and graceful Nav'twir were the main prey of Tajaran hunters, and still are today in rural areas of the planet. \
	Their meat was nice and hearty and healthy, and the thick furs were good for making clothes to keep themselves warm in the snow. As the modern ages came, the hunting of the \
	'striders', as their name translates, slowed as the Tajara started to learn how to capture and farm them for their resources more efficiently. That being said, not that the modern \
	day Adhomai needs their resources less thanks to synthetic fabric and more efficient food sources, both the meat and the fur of the nav'twir has become an export of the Adhomai \
	people. In the olden days, carved nav'twir antlers were used as decoration for pelts and armors."

/obj/item/reagent_containers/food/snacks/meat/rat
	name = "rat meat"
	icon_state = "chickenbreast"
	desc = "You have reached the epitome of poorness: eating the station's vermin."


/obj/item/reagent_containers/food/snacks/meat/rat/Initialize()
	. = ..()
	reagents.add_reagent("protein", 5)
	src.bitesize = 1.5

/obj/item/reagent_containers/food/snacks/meat/dionanymph
	name = "diona nymph meat"
	desc = "A slab of weird green meat."
	icon_state = "plantmeat"

/obj/item/reagent_containers/food/snacks/meat/dionanymph/Initialize()
	. = ..()
	reagents.add_reagent("protein", 6)
