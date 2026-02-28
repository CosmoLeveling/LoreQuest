class_name ItemTemplate
extends PanelContainer

var item_id:String
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name
signal delete(item:String)
func _ready() -> void:
	if Global.items.has(item_id):
		text_edit.text = Global.items.get(item_id).description
		name_label.text = Global.items.get(item_id).name

func _on_text_edit_text_changed() -> void:
	Global.items.get(item_id).description = text_edit.text


func _on_trash_pressed() -> void:
	delete.emit(item_id)
	get_tree().current_scene.start_save_thread()
	queue_free()
