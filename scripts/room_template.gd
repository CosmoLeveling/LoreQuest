class_name RoomTemplate
extends PanelContainer
signal select(current_room:Room)
signal delete(current_room:Room)
signal wall_change(current_room:Room)
signal floor_change(current_room:Room)
var room:Room
@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/LineEdit

func _ready() -> void:
	if room:
		line_edit.text = room.name

func _on_select_pressed() -> void:
	select.emit(room)


func _on_trash_pressed() -> void:
	delete.emit(room)
	queue_free()


func _on_line_edit_text_changed(new_text: String) -> void:
	room.name = new_text
	select.emit(room)


func _on_choose_wall_pressed() -> void:
	wall_change.emit(room)


func _on_choose_floor_pressed() -> void:
	floor_change.emit(room)
