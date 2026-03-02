extends FlowContainer
signal ability_choosen(id:String)
const ABILITY_CHOOSE_TEMPLATE = preload("uid://c3kgmdmfl0h87")
func _reload_abilities(ability_ids:Array,search:String=""):
	for c in %AbilityChooseGrid.get_children():
		c.queue_free()
	for a:String in Globals.abilities.value.keys():
		if ability_ids.has(a):
			continue
		if not a.to_lower().contains(search.to_lower()) and search!="":
			continue
		var tmp:AbilityChooseTemplate = ABILITY_CHOOSE_TEMPLATE.instantiate()
		tmp.ability_id = a
		tmp.choose.connect(func(id):
			ability_choosen.emit(id)
			)
		%AbilityChooseGrid.add_child(tmp)
