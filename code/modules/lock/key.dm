/obj/item/key
	name = "key"
	desc = "Used to unlock things."
	icon = 'icons/obj/items.dmi'
	icon_state = "keys"
	w_class = 1
	var/key_data = ""

/obj/item/key/New(var/newloc,var/data)
	if(data)
		key_data = data
	..(newloc)

/obj/item/key/proc/get_data(var/mob/user)
	return key_data

/obj/item/key/soap
	name = "soap key"
	desc = "a fragile key made using a bar of soap."
	var/uses = 0

/obj/item/key/soap/get_data(var/mob/user)
	uses--
	if(uses <= 0)
		user.drop_from_inventory(src,user)
		to_chat(user, "<span class='warning'>\The [src] crumbles in your hands!</span>")
		qdel(src)
	return ..()

/obj/item/key/material
	var/material/material

/obj/item/key/material/get_material()
	return material

/obj/item/key/material/New(var/newloc, var/new_material)
	..(newloc)
	if(!new_material)
		new_material = DEFAULT_WALL_MATERIAL
	material = SSmaterials.get_material_by_name(new_material)
	if(!material)
		qdel(src)
	name = "[material.display_name] key"
	desc = "A key made from [material.display_name]."
	color = material.icon_colour