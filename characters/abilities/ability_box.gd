extends VBoxContainer

signal ability_deleted(id:String)
signal ability_used(id:String)
const ABILITY_TEMPLATE = preload("uid://chufft44nwvjs")

func reload_abilities(array:Array):
	for c in get_children():
		c.queue_free()
	for ability in array:
		if Globals.abilities.has(ability):
			var tmp: AbilityTemplate = ABILITY_TEMPLATE.instantiate()
			tmp.ability_id = ability
			tmp.delete.connect(ability_deleted.emit)
			tmp.abilityUsed.connect(ability_used.emit)
			add_child(tmp)
