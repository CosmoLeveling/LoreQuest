extends Control

const BACKUPS_TEMPLATE = preload("uid://mqfahftx5qk1")
@onready var backups_container: VBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/ScrollContainer/BackupsContainer

func _ready() -> void:
	var backup_files = DirAccess.get_files_at("user://backups")
	for file_name:String in backup_files:
		var temp:BackupsTemplate = BACKUPS_TEMPLATE.instantiate()
		temp.file_name = file_name
		backups_container.add_child(temp)

func _on_save_pressed() -> void:
	get_tree().current_scene.load_save()
	get_tree().current_scene._reload_characters()
	get_tree().current_scene._reload_worlds()
	get_tree().current_scene.backups_open = false
	get_parent().queue_free()
