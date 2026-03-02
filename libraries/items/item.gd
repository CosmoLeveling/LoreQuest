class_name Item
extends Reactive
var description: ReactiveString = ReactiveString.new("",self)
var name: ReactiveString = ReactiveString.new("",self)
func save()->Dictionary:
	var data:Dictionary = {
		"name":name.value,
		"description":description.value
	}
	return data
static func from_data(node_data:Dictionary)->Item:
	var new_item = Item.new()
	new_item.name.value = node_data.get("name","new_item")
	new_item.description.value = node_data.get("description","")
	return new_item
