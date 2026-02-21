class_name Ability
extends Resource
var mana_cost: int = 0
var description: String = ""
var name: String = ""
func save()->Dictionary:
	var data:Dictionary = {
		"description":description,
		"mana_cost":mana_cost
	}
	return data
