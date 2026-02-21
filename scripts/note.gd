class_name Note
extends Resource
var text: String = ""
var title: String = ""
func save()->Dictionary:
	var data:Dictionary = {
		"title":title,
		"text":text
	}
	return data
