extends Control

const KENNEY_UI = preload("uid://6shp5ck1tnja")

const BACKUPS_MENU = preload("uid://dren5fnwqpe4r")
const CHARACTER_TEMPLATE = preload("uid://c1ef73xwn2auw")
const CHARACTER_MENU = preload("uid://d1klvxp06pdqr")
const WORLD_MENU = preload("uid://bixurgfj88yg3")
const WORLD_TEMPLATE = preload("uid://dhee4wvahq1f6")
const ABILITY_TEMPLATE = preload("uid://chufft44nwvjs")
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
const ITEM_TEMPLATE = preload("uid://demp65srmd3xs")
@onready var item_grid: FlowContainer = $MarginContainer/VBoxContainer/TabContainer/Libraries/TabContainer/Items/VBoxContainer/ScrollContainer/ItemGrid

#region OnReadys
@onready var windows: Control = $Windows
@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Title
@onready var character_grid: FlowContainer = $MarginContainer/VBoxContainer/TabContainer/Characters/VBoxContainer2/VBoxContainer/ScrollContainer/CharacterGrid
@onready var themes_button: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/ThemesButton

@onready var world_grid: FlowContainer = $MarginContainer/VBoxContainer/TabContainer/Worlds/VBoxContainer/ScrollContainer/WorldGrid

@onready var amount: Label = $MarginContainer/VBoxContainer/TabContainer/Characters/VBoxContainer2/Amount

#region Character Creation
@onready var image_text: TextureRect = $CharacterCreate/ImageSelect/MarginContainer/VBoxContainer/Image
@onready var name_line: LineEdit = $CharacterCreate/NameSelect/MarginContainer/VBoxContainer/NameLine
@onready var name_select: PanelContainer = $CharacterCreate/NameSelect
@onready var image_select: PanelContainer = $CharacterCreate/ImageSelect
@onready var character_create: CenterContainer = $CharacterCreate
#endregion
@onready var ability_grid: FlowContainer = $MarginContainer/VBoxContainer/TabContainer/Libraries/TabContainer/Abilities/VBoxContainer/ScrollContainer/AbilityGrid
@onready var item_name_line: LineEdit = $ItemCreate/NameSelect/MarginContainer/VBoxContainer/ItemNameLine
@onready var item_create: CenterContainer = $ItemCreate

#region world Creation
@onready var world_image_text: TextureRect = $WorldCreate/WorldImageSelect/MarginContainer/VBoxContainer/WorldImageText
@onready var world_name_line: LineEdit = $WorldCreate/WorldNameSelect/MarginContainer/VBoxContainer/WorldNameLine
@onready var world_name_select: PanelContainer = $WorldCreate/WorldNameSelect
@onready var world_image_select: PanelContainer = $WorldCreate/WorldImageSelect
@onready var world_create: CenterContainer = $WorldCreate
#endregion
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
@onready var ability_create: CenterContainer = $AbilityCreate
@onready var ability_name_line: LineEdit = $AbilityCreate/NameSelect/MarginContainer/VBoxContainer/AbilityNameLine

#endregion

var backups_open:bool = false

@export var themes:Dictionary[String,Theme]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i_theme in themes.keys():
		themes_button.add_item(i_theme)
	get_tree().root.theme = themes["Default"]
	thread = Thread.new()
	await load_save()
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)

	if not DirAccess.dir_exists_absolute(backups_dir):
		DirAccess.make_dir_absolute(backups_dir)
	_reload_characters()
	_reload_worlds()
	_reload_abilities()
	_reload_items()

func _reload_abilities():
	for c in ability_grid.get_children():
		c.queue_free()
	for a:String in Global.abilities.keys():
		var ability:AbilityTemplate = ABILITY_TEMPLATE.instantiate()
		ability.ability_id = a
		ability_grid.add_child(ability)
		ability.delete.connect(delete_ability)
		ability.ability_use_button.disabled = true
func _reload_items():
	for c in item_grid.get_children():
		c.queue_free()
	for i:String in Global.items.keys():
		var item:ItemTemplate = ITEM_TEMPLATE.instantiate()
		item.item_id = i
		item_grid.add_child(item)
		item.delete.connect(delete_item)
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
	if not character.open:
		character.open = true
		var window = Window.new()
		window.content_scale_size = get_viewport_rect().size
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		var menu = CHARACTER_MENU.instantiate()
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
		menu.character = character
		windows.add_child(window)
		window.title = character.name
		window.add_child(menu)

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
	if not world.open:
		world.open = true
		var window = Window.new()
		window.content_scale_size = get_viewport_rect().size
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		var menu = WORLD_MENU.instantiate()
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
		menu.world = world
		windows.add_child(window)
		window.title = world.name
		window.add_child(menu)

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
	_load_items()
	_load_abilities()
	_load_settings()
	_load_characters()
	_load_worlds()

func _load_settings() -> void:
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if not FileAccess.file_exists(save_dir + "/"+addon+"settings.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/"+addon+"settings.save", FileAccess.READ)
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
		var node_data:Dictionary = json.data

		if themes.has(node_data.get("theme","Default")):
			var option:String = node_data.get("theme","Default")
			for i in range(themes_button.get_item_count()):
				if themes_button.get_item_text(i) == option:
					themes_button.select(i)
			get_tree().root.theme = themes[option]

func _load_abilities() -> void:
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if not FileAccess.file_exists(save_dir + "/"+addon+"abilities.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/"+addon+"abilities.save", FileAccess.READ)
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
		var node_data:Dictionary = json.data
		var ability:Ability = Ability.from_data(node_data)
		Global.abilities.set(ability.name,ability)

func _load_items() -> void:
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if not FileAccess.file_exists(save_dir + "/"+addon+"items.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/"+addon+"items.save", FileAccess.READ)
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
		var node_data:Dictionary = json.data
		var item:Item = Item.from_data(node_data)
		Global.items.set(item.name,item)

func _load_characters() -> void:
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if not FileAccess.file_exists(save_dir + "/"+addon+"characters.save"):
		return # Error! We don't have a save to load.

	characters.clear()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/"+addon+"characters.save", FileAccess.READ)
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
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if not FileAccess.file_exists(save_dir+"/"+addon+"worlds.save"):
		return # Error! We don't have a save to load.

	worlds.clear()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir+"/"+addon+"worlds.save", FileAccess.READ)
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
	_save_items()
	_save_abilities()
	_save_settings()
	_save_characters()
	_save_worlds()

func _save_settings():
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_file = FileAccess.open(save_dir+"/"+addon+"settings.save",FileAccess.WRITE)
	var data:Dictionary = {
		"theme":themes_button.get_item_text(themes_button.get_item_index(themes_button.get_selected_id()))
	}
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func _save_abilities():
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_file = FileAccess.open(save_dir+"/"+addon+"abilities.save",FileAccess.WRITE)
	for ability in Global.abilities.values():
		var json_string = JSON.stringify(ability.save())
		save_file.store_line(json_string)

func _save_items():
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_file = FileAccess.open(save_dir+"/"+addon+"items.save",FileAccess.WRITE)
	for item in Global.items.values():
		var json_string = JSON.stringify(item.save())
		save_file.store_line(json_string)

func _save_characters():
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_file = FileAccess.open(save_dir+"/"+addon+"characters.save",FileAccess.WRITE)
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
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_file = FileAccess.open(save_dir+"/"+addon+"worlds.save",FileAccess.WRITE)
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

func _exit_tree() -> void:
	start_save_thread()
	thread.wait_to_finish()


func _on_saves_folder_pressed() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(save_dir))


func _on_backups_pressed() -> void:
	if not backups_open:
		backups_open=true
		var window = Window.new()
		window.content_scale_size = get_viewport_rect().size
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		var menu = BACKUPS_MENU.instantiate()
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
		windows.add_child(window)
		window.title = "backup"
		window.add_child(menu)


func _on_themes_button_item_selected(index: int) -> void:
	var option:String  = themes_button.get_item_text(index)
	get_tree().root.theme = themes[option]


func _on_tab_container_tab_changed(tab: int) -> void:
	if tab_container:
		_reload_abilities()
		_reload_items()
		_reload_worlds()
		_reload_characters()
		title.text = tab_container.get_tab_control(tab).name


func _on_new_ability_pressed() -> void:
	ability_create.show()


func _on_submit_ability_name_pressed() -> void:
	var new_ability = Ability.new()
	new_ability.name = ability_name_line.text
	Global.abilities.set(new_ability.name,new_ability)
	ability_create.hide()
	_reload_abilities()
	start_save_thread()

func delete_ability(ability_id):
	Global.abilities.erase(ability_id)

func _on_new_item_pressed() -> void:
	item_create.show()

func _on_submit_item_name_pressed() -> void:
	var new_item = Item.new()
	new_item.name = item_name_line.text
	Global.items.set(new_item.name,new_item)
	item_create.hide()
	_reload_items()
	start_save_thread()

func delete_item(item_id):
	Global.items.erase(item_id)
