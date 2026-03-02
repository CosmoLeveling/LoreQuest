class_name BackupsTemplate
extends PanelContainer
const save_dir = "user://saves"
const backups_dir = "user://backups"
var file_name:String = ""
@onready var backup_name: Label = $MarginContainer/VBoxContainer/HBoxContainer2/BackupName

func _ready() -> void:
	backup_name.text = file_name

func _on_trash_pressed() -> void:
	DirAccess.remove_absolute("user://backups/"+file_name)
	queue_free()

func _on_flashback_pressed() -> void:
	get_tree().current_scene.save()
	var backup_file = FileAccess.open("user://backups/"+file_name,FileAccess.READ)
	var type:String = "worlds"
	if file_name.contains("characters"):
		type = "characters"
	_create_backup(type)
	var save_file = FileAccess.open("user://saves/"+type+".save",FileAccess.WRITE)
	save_file.store_string(backup_file.get_as_text())
	DirAccess.remove_absolute("user://backups/"+file_name)
	queue_free()
func _create_backup(type:String):
	var final_time:String = ""
	var time_dict:Dictionary = Time.get_datetime_dict_from_system()
	final_time+=str(time_dict.get("year"))
	final_time+="-"+str(time_dict.get("month"))
	final_time+="-"+str(time_dict.get("day"))
	final_time+="-"+str(time_dict.get("hour"))
	final_time+="-"+str(time_dict.get("minute"))
	final_time+="-"+str(time_dict.get("second"))
	if FileAccess.file_exists(save_dir + "/"+type+".save"):
		var save_file = FileAccess.open(save_dir + "/"+type+".save",FileAccess.READ)
		var backup_file = FileAccess.open(backups_dir + "/"+final_time+"-"+type+".backup",FileAccess.WRITE)
		backup_file.store_string(save_file.get_as_text())
