extends PanelContainer

var item:Item
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name

func _ready() -> void:
	if item:
		name = item.name
		text_edit.text = item.description
		name_label.text = name

func _on_text_edit_text_changed() -> void:
	item.description = text_edit.text


func _on_trash_pressed() -> void:
	for c in get_tree().current_scene.current_menu.get_children():
		c.character.items.erase(item)
	get_tree().current_scene.start_save_thread()
	queue_free()
