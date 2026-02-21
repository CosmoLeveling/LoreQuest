extends Control
const BACKUPS_MENU = preload("uid://dren5fnwqpe4r")
const CHARACTER_TEMPLATE = preload("uid://c1ef73xwn2auw")
const CHARACTER_MENU = preload("uid://d1klvxp06pdqr")
const WORLD_MENU = preload("uid://bixurgfj88yg3")
const WORLD_TEMPLATE = preload("uid://dhee4wvahq1f6")
const save_dir = "user://saves"
const backups_dir = "user://backups"
var characters: Array[Character] = [
]
var worlds: Array[World] = [
]
var thread:Thread
var new_name:String
var new_image:String
#region Exports
#endregion

#region OnReadys
@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Title
@onready var character_grid: GridContainer = $MarginContainer/VBoxContainer/CharactersMenu/VBoxContainer2/VBoxContainer/ScrollContainer/CenterContainer/CharacterGrid
@onready var current_menu: Node = $CurrentMenu

@onready var world_grid: GridContainer = $MarginContainer/VBoxContainer/WorldsMenu/VBoxContainer/ScrollContainer/CenterContainer/WorldGrid
@onready var characters_button: Button = $MarginContainer/VBoxContainer/HBoxContainer3/CharactersButton
@onready var worlds_button: Button = $MarginContainer/VBoxContainer/HBoxContainer3/WorldsButton
@onready var characters_menu: Control = $MarginContainer/VBoxContainer/CharactersMenu
@onready var worlds_menu: Control = $MarginContainer/VBoxContainer/WorldsMenu

@onready var amount: Label = $MarginContainer/VBoxContainer/CharactersMenu/VBoxContainer2/Amount

#region Character Creation
@onready var image_text: TextureRect = $CharacterCreate/ImageSelect/MarginContainer/VBoxContainer/Image
@onready var name_line: LineEdit = $CharacterCreate/NameSelect/MarginContainer/VBoxContainer/NameLine
@onready var name_select: PanelContainer = $CharacterCreate/NameSelect
@onready var image_select: PanelContainer = $CharacterCreate/ImageSelect
@onready var character_create: CenterContainer = $CharacterCreate
#endregion

#region world Creation
@onready var world_image_text: TextureRect = $WorldCreate/WorldImageSelect/MarginContainer/VBoxContainer/WorldImageText
@onready var world_name_line: LineEdit = $WorldCreate/WorldNameSelect/MarginContainer/VBoxContainer/WorldNameLine
@onready var world_name_select: PanelContainer = $WorldCreate/WorldNameSelect
@onready var world_image_select: PanelContainer = $WorldCreate/WorldImageSelect
@onready var world_create: CenterContainer = $WorldCreate
#endregion

#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread = Thread.new()
	await load_save()
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	if not DirAccess.dir_exists_absolute(backups_dir):
		DirAccess.make_dir_absolute(backups_dir)
	_reload_characters()
	
	_reload_worlds()

#region Backup
func _on_backup_pressed() -> void:
	save()
	_create_backup()

func _create_backup():
	var final_time:String = ""
	var time_dict:Dictionary = Time.get_datetime_dict_from_system()
	final_time+=str(time_dict.get("year"))
	final_time+="-"+str(time_dict.get("month"))
	final_time+="-"+str(time_dict.get("day"))
	final_time+="-"+str(time_dict.get("hour"))
	final_time+="-"+str(time_dict.get("minute"))
	final_time+="-"+str(time_dict.get("second"))
	if FileAccess.file_exists(save_dir + "/characters.save"):
		var save_file = FileAccess.open(save_dir + "/characters.save",FileAccess.READ)
		var backup_file = FileAccess.open(backups_dir + "/"+final_time+"-characters.backup",FileAccess.WRITE)
		backup_file.store_string(save_file.get_as_text())
	if FileAccess.file_exists(save_dir + "/worlds.save"):
		var save_file = FileAccess.open(save_dir + "/worlds.save",FileAccess.READ)
		var backup_file = FileAccess.open(backups_dir + "/"+final_time+"-worlds.backup",FileAccess.WRITE)
		backup_file.store_string(save_file.get_as_text())
#endregion

#region Character Management

func _reload_characters() -> void:
	for c in character_grid.get_children():
		c.queue_free()
	for c:Character in characters:
		var character:CharacterTemplate = CHARACTER_TEMPLATE.instantiate()
		character.character = c
		character.open_character.connect(open_character)
		character_grid.add_child(character)
		character.deleted.connect(start_save_thread)
	amount.text = "Current Amount: "+str(characters.size())

func open_character(character:Character):
	var menu = CHARACTER_MENU.instantiate()
	menu.character = character
	$CurrentMenu.add_child(menu)

func _sort_characters() -> void:
	var char_dict: Dictionary[String,Character]
	for c:Character in characters:
		char_dict[c.name] = c
	char_dict.sort()
	characters = char_dict.values()
#endregion

#region World Management

func _reload_worlds() -> void:
	for c in world_grid.get_children():
		c.queue_free()
	for c:World in worlds:
		var world:WorldTemplate = WORLD_TEMPLATE.instantiate()
		world.world = c
		world.open_world.connect(open_world)
		world_grid.add_child(world)
		world.deleted.connect(start_save_thread)

func open_world(world:World):
	var menu = WORLD_MENU.instantiate()
	menu.world = world
	$CurrentMenu.add_child(menu)

func _sort_worlds() -> void:
	var world_dict: Dictionary[String,World]
	for c:World in worlds:
		world_dict[c.name] = c
	world_dict.sort()
	worlds = world_dict.values()
#endregion

#region Character/World Creation

#region Character Create
func _on_button_pressed() -> void:
	name_select.show()
	character_create.show()
	name_line.text = ""
	var image_texture = ImageTexture.new()
	image_texture.set_image(load("res://assets/default.png"))
	image_text.texture = image_texture
	new_image = ""

func _on_submit_image_pressed() -> void:
	image_select.hide()
	character_create.hide()
	var c = Character.new(new_name,new_image)
	var character:CharacterTemplate = CHARACTER_TEMPLATE.instantiate()
	character.character = c
	character.open_character.connect(open_character)
	character_grid.add_child(character)
	characters.append(c)
	_sort_characters()
	amount.text = "Current Amount:"+str(characters.size())
	character.deleted.connect(start_save_thread)
	start_save_thread()

func _on_submit_name_pressed() -> void:
	new_name = name_line.text
	name_select.hide()
	image_select.show()
#endregion

#region World Create
func _on_world_create_pressed() -> void:
	world_name_select.show()
	world_create.show()
	world_name_line.text = ""
	var image_texture = ImageTexture.new()
	image_texture.set_image(load("res://assets/default_world.png"))
	world_image_text.texture = image_texture
	new_image = ""

func _on_world_submit_image_pressed() -> void:
	world_image_select.hide()
	world_create.hide()
	var c = World.new(new_name,new_image)
	var world:WorldTemplate = WORLD_TEMPLATE.instantiate()
	world.world = c
	world.open_world.connect(open_world)
	world_grid.add_child(world)
	worlds.append(c)
	_sort_worlds()
	world.deleted.connect(start_save_thread)
	start_save_thread()

func _on_world_submit_name_pressed() -> void:
	new_name = world_name_line.text
	world_name_select.hide()
	world_image_select.show()
#endregion

func _on_choose_image_pressed() -> void:
	$FileDialog.popup()
func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	image_text.texture = image_texture
	world_image_text.texture = image_texture
	new_image = path

#endregion

#region Saving/Loading
func start_save_thread():
	if thread.is_started():
		thread.wait_to_finish()
	thread.start(save)

func load_save():
	_load_characters()
	_load_worlds()

func _load_characters() -> void:
	if not FileAccess.file_exists(save_dir + "/characters.save"):
		return # Error! We don't have a save to load.

	characters.clear()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/characters.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		var character = Character.from_date(node_data)
		characters.append(character)

func _load_worlds() -> void:
	if not FileAccess.file_exists(save_dir+"/worlds.save"):
		return # Error! We don't have a save to load.

	worlds.clear()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/worlds.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		var world = World.from_date(node_data)
		worlds.append(world)

func save():
	_save_characters()
	_save_worlds()

func _save_characters():
	var save_file = FileAccess.open(save_dir+"/characters.save",FileAccess.WRITE)
	for c:Character in characters:
		# Check the node has a save function.
		if !c.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % c.name)
			continue
		# Call the node's save function.
		var character_data:Dictionary = c.call("save")
		
		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(character_data)
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	amount.set_deferred("text", "Current Amount: "+str(characters.size()))
func _save_worlds():
	var save_file = FileAccess.open(save_dir+"/worlds.save",FileAccess.WRITE)
	for c:World in worlds:
		# Check the node has a save function.
		if !c.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % c.name)
			continue
		# Call the node's save function.
		var world_data:Dictionary = c.call("save")
		
		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(world_data)
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

#endregion

#region Tabs
func _on_characters_pressed() -> void:
	characters_button.disabled = true
	worlds_button.disabled = false
	characters_menu.show()
	worlds_menu.hide()
	title.text = "Characters"

func _on_worlds_pressed() -> void:
	characters_button.disabled = false
	worlds_button.disabled = true
	characters_menu.hide()
	worlds_menu.show()
	title.text = "Worlds"
#endregion

func _exit_tree() -> void:
	start_save_thread()
	thread.wait_to_finish()


func _on_saves_folder_pressed() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(save_dir))


func _on_backups_pressed() -> void:
	var menu = BACKUPS_MENU.instantiate()
	$CurrentMenu.add_child(menu)
