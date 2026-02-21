class_name NoteTemplate
extends PanelContainer

var note:Note
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit

func _ready() -> void:
	if note:
		text_edit.text = note.text

func _on_text_edit_text_changed() -> void:
	note.text = text_edit.text


func _on_trash_pressed() -> void:
	for c in get_tree().current_scene.current_menu.get_children():
		c.character.notes.erase(note)
	get_tree().current_scene.start_save_thread()
	queue_free()


func _on_line_edit_text_changed(new_text: String) -> void:
	note.title = new_text
