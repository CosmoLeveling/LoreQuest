class_name Ability
extends Reactive
var mana_cost: ReactiveInt = ReactiveInt.new(0,self)
var description: ReactiveString = ReactiveString.new("",self)
var name: ReactiveString = ReactiveString.new("",self)
func save()->Dictionary:
	var data:Dictionary = {
		"name":name.value,
		"description":description.value,
		"mana_cost":mana_cost.value,
	}
	return data
static func from_data(node_data:Dictionary)->Ability:
	var new_ability = Ability.new()
	new_ability.name.value = node_data.get("name","new_ability")
	new_ability.description.value = node_data.get("description","")
	new_ability.mana_cost.value = node_data.get("mana_cost",0)
	return new_ability
