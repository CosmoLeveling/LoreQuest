class_name AbilityChooseTemplate
extends PanelContainer
signal choose(ability:String)
var ability_id:String
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name

func _ready() -> void:
	if Globals.abilities.has(ability_id):
		name_label.text = ability_id


func _on_ability_choose_button_pressed() -> void:
	choose.emit(ability_id)
