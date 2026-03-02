extends GridContainer
signal open_gallery_image(path:String)
signal open_avatar_image(path:String)
const AVATAR_TEMPLATE = preload("uid://b3abye6b076tm")
const GALLERY_TEMPLATE = preload("uid://b8byq3d2opaqo")

func reload_gallery(character:Character,array:Array):
	for c in get_children():
		c.queue_free()
	var _temp:AvatarTemplate = AVATAR_TEMPLATE.instantiate()
	_temp.image_path = character.image_path.value
	_temp.open_image.connect(func(path):open_avatar_image.emit(path))
	add_child(_temp)
	for a in array:
		var tmp:GalleryTemplate=GALLERY_TEMPLATE.instantiate()
		tmp.image_path = a
		tmp.deleted.connect(func(path):character.gallery_images.erase(path))
		tmp.open_image.connect(func(path):open_gallery_image.emit(path))
		add_child(tmp)
