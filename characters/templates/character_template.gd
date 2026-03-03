class_name CharacterTemplate
extends PanelContainer

signal open_character
signal deleted
@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var avatar: TextureRect = $MarginContainer/VBoxContainer/Avatar

var character:Character

func _ready() -> void:
	refresh_visuals()

func refresh_visuals():
	if character:
		character.name.reactive_changed.connect(func(reactive):name_label.text=reactive.value)
		character.image_path.reactive_changed.connect(func(reactive):
			var image:Image = Image.new()
			if FileAccess.file_exists(reactive.value):
				image.load(reactive.value)
				image = Globals.center_crop(image)
			else:
				image = load("res://icons/default.png")
			
			var image_texture = ImageTexture.new()
			image_texture.set_image(image)
			
			avatar.texture = image_texture
			)
		character.name.manually_emit()
		character.image_path.manually_emit()


func _on_open_pressed() -> void:
	open_character.emit(character)


func _on_delete_pressed() -> void:
	deleted.emit()
	Globals.characters.erase(character)
	queue_free()
