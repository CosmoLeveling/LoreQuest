class_name CharacterTemplate
extends PanelContainer

signal open_character
signal deleted
@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var avatar: TextureRect = $MarginContainer/VBoxContainer/Avatar

var character:Character

func _ready() -> void:
	if character:
		name_label.text = character.name
		var image:Image = Image.new()
		if FileAccess.file_exists(character.image_path):
			image.load(character.image_path)
			image = Global.center_crop(image)
		else:
			image = load("res://assets/default.png")
		
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		
		avatar.texture = image_texture


func _on_open_pressed() -> void:
	open_character.emit(character)


func _on_delete_pressed() -> void:
	deleted.emit()
	get_tree().current_scene.characters.erase(character)
	queue_free()
