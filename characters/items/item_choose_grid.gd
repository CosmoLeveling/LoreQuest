extends FlowContainer
signal item_choosen(id:String)
const ITEM_CHOOSE_TEMPLATE = preload("uid://dae1ixfharnwh")

func _reload_items(item_ids:Array,search:String=""):
	for c in get_children():
		c.queue_free()
	for a:String in Globals.items.value.keys():
		if item_ids.has(a):
			continue
		if not a.to_lower().contains(search.to_lower()) and search!="":
			continue
		var tmp:ItemChooseTemplate = ITEM_CHOOSE_TEMPLATE.instantiate()
		tmp.item_id = a
		tmp.choose.connect(func(id):
			item_choosen.emit(id)
			)
		add_child(tmp)
