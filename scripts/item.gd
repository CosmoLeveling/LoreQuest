class_name Item
extends Resource
var description: String = ""
var name: String = ""
func save()->Dictionary:
	var data:Dictionary = {
		"name":name,
		"description":description
	}
	return data
static func from_data(node_data:Dictionary)->Item:
	var new_item = Item.new()
	new_item.name = node_data.get("name","new_item")
	new_item.description = node_data.get("description","")
	return new_item
