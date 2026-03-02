class_name AbilityTemplate
extends PanelContainer
signal abilityUsed(id:String)
signal delete(id:String)
var ability_id:String
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SpinBox
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name
@onready var ability_use_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/AbilityUseButton

func _ready() -> void:
	if Globals.abilities.has(ability_id):
		var ability:Ability = Globals.abilities.get_at(ability_id)
		Globals.abilities.get_at(ability_id).name.reactive_changed.connect(func(reactive):
			if name_label.text != reactive.value:
				name_label.text=reactive.value)
		Globals.abilities.get_at(ability_id).description.reactive_changed.connect(func(reactive):
			if text_edit.text != reactive.value:
				text_edit.text=reactive.value)
		Globals.abilities.get_at(ability_id).mana_cost.reactive_changed.connect(func(reactive):
			if spin_box.value != reactive.value:
				spin_box.value=reactive.value
			)
		text_edit.text_changed.connect(func():
			Globals.abilities.get_at(ability_id).description.value = text_edit.text
			)
		spin_box.value_changed.connect(func(value):
			Globals.abilities.get_at(ability_id).mana_cost.value = value
			)
		ability.name.manually_emit()
		ability.description.manually_emit()
		ability.mana_cost.manually_emit()
		ability_use_button.pressed.connect(func():abilityUsed.emit(ability_id))
func _on_trash_pressed() -> void:
	delete.emit(ability_id)
	get_tree().current_scene.start_save_thread()
	queue_free()
