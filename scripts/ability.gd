class_name Ability
extends Resource
var mana_cost: int = 0
var description: String = ""
var name: String = ""
func save()->Dictionary:
	var data:Dictionary = {
		"name":name,
		"description":description,
		"mana_cost":mana_cost,
	}
	return data
static func from_data(node_data:Dictionary)->Ability:
	var new_ability = Ability.new()
	new_ability.name = node_data.get("name","new_ability")
	new_ability.description = node_data.get("description","")
	new_ability.mana_cost = node_data.get("mana_cost",0)
	return new_ability
