class_name RaceTemplate
extends PanelContainer

signal race_selected
signal race_deleted

var race:Race:
	set(v):
		if race != v:
			race = v


func _on_open_pressed() -> void:
	race_selected.emit(race)


func _on_delete_pressed() -> void:
	race_deleted.emit()
	Globals.races.erase(race.name.value)
	queue_free()

