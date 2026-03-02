class_name NoteTemplate
extends PanelContainer
signal delete_note(note:Note)
var note:Note
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $MarginContainer/VBoxContainer/LineEdit

func _ready() -> void:
	if note:
		note.title.reactive_changed.connect(func(reactive):
			if line_edit.text!=reactive.value:
				line_edit.text = reactive.value
			)
		note.text.reactive_changed.connect(func(reactive):
			if text_edit.text!=reactive.value:
				text_edit.text = reactive.value
			)
		line_edit.text_changed.connect(func(text):note.title.value=line_edit.text)
		text_edit.text_changed.connect(func():note.text.value=text_edit.text)
		note.text.manually_emit()
		note.title.manually_emit()

func _on_trash_pressed() -> void:
	delete_note.emit(note)
	get_tree().current_scene.start_save_thread()
	queue_free()
