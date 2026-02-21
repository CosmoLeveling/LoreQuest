class_name Item
extends Resource
var description: String = ""
var name: String = ""
func save()->Dictionary:
	var data:Dictionary = {
		"description":description
	}
	return data
