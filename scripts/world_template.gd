class_name WorldTemplate
extends PanelContainer

signal open_world
signal deleted
@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var avatar: TextureRect = $MarginContainer/VBoxContainer/Avatar

var world:World

func _ready() -> void:
	if world:
		name_label.text = world.name
		var image:Image = Image.new()
		if FileAccess.file_exists(world.image_path):
			image.load(world.image_path)
			image = Global.center_crop(image)
		else:
			image = load("res://assets/default_world.png")
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		avatar.texture = image_texture


func _on_open_pressed() -> void:
	open_world.emit(world)


func _on_delete_pressed() -> void:
	deleted.emit()
	get_tree().current_scene.worlds.erase(world)
	queue_free()
