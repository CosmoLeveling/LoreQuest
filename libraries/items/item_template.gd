class_name ItemTemplate
extends PanelContainer

var item_id:String
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/name
signal delete(item:String)
func _ready() -> void:
	if Globals.items.has(item_id):
		var item:Item = Globals.items.get_at(item_id)
		Globals.items.get_at(item_id).name.reactive_changed.connect(func(reactive):
			if name_label.text != reactive.value:
				name_label.text=reactive.value)
		Globals.items.get_at(item_id).description.reactive_changed.connect(func(reactive):
			if text_edit.text != reactive.value:
				text_edit.text=reactive.value)
		text_edit.text_changed.connect(func():
			Globals.items.get_at(item_id).description.value = text_edit.text
			)
		item.name.manually_emit()
		item.description.manually_emit()


func _on_trash_pressed() -> void:
	delete.emit(item_id)
	get_tree().current_scene.start_save_thread()
	queue_free()
