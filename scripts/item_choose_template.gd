class_name ItemChooseTemplate
extends PanelContainer
signal choose(item:String)
var item_id:String
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name

func _ready() -> void:
	if Global.items.has(item_id):
		name_label.text = Global.items.get(item_id).name


func _on_ability_choose_button_pressed() -> void:
	choose.emit(item_id)
