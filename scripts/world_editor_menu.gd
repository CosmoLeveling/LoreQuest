extends Control

var world:World
@onready var world_editor: Control = $MarginContainer/VBoxContainer/PanelContainer/SubViewportContainer/SubViewport/WorldEditor

func _ready() -> void:
	world_editor.world = world
	world_editor.init()


func _on_save_pressed() -> void:
	get_tree().current_scene.start_save_thread()
	queue_free()
