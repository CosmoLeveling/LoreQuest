extends Node

var abilities:Dictionary[String,Ability]
var items:Dictionary[String,Item]
func center_crop(image:Image)->Image:
	var new_image = Image.new()
	var new_size = image.get_height()
	var new_pos = abs(image.get_width()-image.get_height())
	var new_pos_val = Vector2(new_pos,0)
	if image.get_width()<new_size:
		new_pos_val = Vector2(0,new_pos/2)
		new_size=image.get_width()
	new_image=Image.create(new_size,new_size, false,image.get_format())
	new_image.blit_rect(image,Rect2i(new_pos_val.x,new_pos_val.y,new_size+new_pos_val.x,new_size+new_pos_val.y),Vector2.ZERO)
	return new_image
