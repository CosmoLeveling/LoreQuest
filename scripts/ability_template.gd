extends PanelContainer

signal abilityUsed
var ability:Ability
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SpinBox
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name

func _ready() -> void:
	if ability:
		name = ability.name
		text_edit.text = ability.description
		name_label.text = name
		spin_box.value = ability.mana_cost

func _on_spin_box_value_changed(value: float) -> void:
	ability.mana_cost = int(value)

func _on_button_pressed() -> void:
	abilityUsed.emit(ability.mana_cost,self)


func _on_text_edit_text_changed() -> void:
	ability.description = text_edit.text


func _on_trash_pressed() -> void:
	for c in get_tree().current_scene.current_character.get_children():
		c.character.abilities.erase(ability)
	get_tree().current_scene.start_save_thread()
	queue_free()
