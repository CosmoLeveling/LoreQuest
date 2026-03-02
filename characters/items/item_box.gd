extends VBoxContainer

signal item_deleted(id:String)
const ITEM_TEMPLATE = preload("uid://demp65srmd3xs")

func reload_items(array:Array):
	for c in get_children():
		c.queue_free()
	for item in array:
		if Globals.items.has(item):
			var tmp: ItemTemplate = ITEM_TEMPLATE.instantiate()
			tmp.item_id = item
			tmp.delete.connect(item_deleted.emit)
			add_child(tmp)
