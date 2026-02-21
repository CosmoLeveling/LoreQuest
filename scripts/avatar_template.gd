class_name AvatarTemplate
extends PanelContainer

signal open_image(path:String)
var image_path:String = ""
@onready var avatar: TextureRect = $MarginContainer/VBoxContainer/Avatar

func _ready() -> void:
	var image: Image = Image.new()
	image.load(image_path)
	image = Global.center_crop(image)
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.set_image(image)
	avatar.texture = image_texture

func _on_button_pressed() -> void:
	open_image.emit(image_path)
