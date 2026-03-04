extends Node

var abilities:ReactiveDictionary = ReactiveDictionary.new()
var items:ReactiveDictionary = ReactiveDictionary.new()
var characters: ReactiveArray = ReactiveArray.new()

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

func _ready() -> void:
	abilities.reactive_changed.connect(
		func (reactive:Reactive):
			for c:Character in characters.value:
				for a in c.ability_ids.value:
					if reactive.has(a):
						continue
					c.ability_ids.erase(a)
			)
	items.reactive_changed.connect(
		func (reactive:Reactive):
			for c:Character in characters.value:
				for i in c.item_ids.value:
					if reactive.has(i):
						continue
					c.item_ids.erase(i)
			)
