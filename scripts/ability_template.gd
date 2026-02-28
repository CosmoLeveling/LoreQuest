class_name AbilityTemplate
extends PanelContainer
signal abilityUsed
signal delete
var ability_id:String
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SpinBox
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name
@onready var ability_use_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/AbilityUseButton

func _ready() -> void:
	if Global.abilities.has(ability_id):
		text_edit.text = Global.abilities.get(ability_id).description
		name_label.text = Global.abilities.get(ability_id).name
		spin_box.value = Global.abilities.get(ability_id).mana_cost

func _on_spin_box_value_changed(value: float) -> void:
	Global.abilities.get(ability_id).mana_cost = int(value)
	get_tree().current_scene.start_save_thread()


func _on_button_pressed() -> void:
	abilityUsed.emit(Global.abilities.get(ability_id).mana_cost,self)
	get_tree().current_scene.start_save_thread()


func _on_text_edit_text_changed() -> void:
	Global.abilities.get(ability_id).description = text_edit.text
	get_tree().current_scene.start_save_thread()


func _on_trash_pressed() -> void:
	delete.emit(ability_id)
	get_tree().current_scene.start_save_thread()
	queue_free()
