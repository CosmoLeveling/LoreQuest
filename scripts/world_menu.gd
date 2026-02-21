extends Control
@onready var file_dialog: FileDialog = $FileDialog
@onready var map_file_dialog: FileDialog = $MapFileDialog
@onready var avatar: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Avatar
@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Name
@onready var description: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Description
@onready var world_history: TextEdit = $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/WorldHistory/VBoxContainer/WorldHistory
@onready var world_map: TextureRect = $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/WorldMap/VBoxContainer/WorldMap
const WORLD_EDITOR_MENU = preload("uid://cqad5ks87iorf")

var world:World
func _ready() -> void:
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
	var map_image:Image = Image.new()
	if FileAccess.file_exists(world.world_map_path):
		map_image.load(world.world_map_path)
	else:
		map_image = load("res://assets/default_world_map.png")
	var map_image_texture = ImageTexture.new()
	map_image_texture.set_image(map_image)
	world_map.texture = map_image_texture
	description.text = world.description
	world_history.text = world.history


func _on_change_image_pressed() -> void:
	file_dialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	image = Global.center_crop(image)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	avatar.texture = image_texture
	world.image_path = path

func _on_save_pressed() -> void:
	get_tree().current_scene.start_save_thread()
	get_tree().current_scene._reload_worlds()
	queue_free()

func _on_description_text_changed() -> void:
	world.description = description.text


func _on_world_history_text_changed() -> void:
	world.history = world_history.text


func _on_map_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	world_map.texture = image_texture
	world.world_map_path = path


func _on_choose_map_pressed() -> void:
	map_file_dialog.popup()


func _on_world_edit_pressed() -> void:
	var editor = WORLD_EDITOR_MENU.instantiate()
	editor.world = world
	$WorldEditor.add_child(editor)
