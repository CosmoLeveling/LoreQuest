extends Control

const BACKUPS_MENU = preload("uid://dren5fnwqpe4r")
const CHARACTER_TEMPLATE = preload("uid://c1ef73xwn2auw")
const CHARACTER_MENU = preload("uid://d1klvxp06pdqr")
const WORLD_MENU = preload("uid://bixurgfj88yg3")
const WORLD_TEMPLATE = preload("uid://dhee4wvahq1f6")
const ABILITY_TEMPLATE = preload("uid://chufft44nwvjs")
const save_dir = "user://saves"
const backups_dir = "user://backups"
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CharacterSearch.text_changed.connect(func(_value):_reload_characters(Globals.characters.value))
	%GroupFilter.item_selected.connect(func(_value):_reload_characters(Globals.characters.value))
	%WorldSearch.text_changed.connect(func(_value):_reload_worlds())
	Globals.characters.reactive_changed.connect(func(reactive): _reload_characters(reactive.value))
	
	themes_button.add_item("Default")

	for c_theme in DirAccess.get_files_at("user://themes/"):
		if c_theme.ends_with(".json"):
			Globals.themes.set_at(c_theme.trim_suffix(".json"), "user://themes/"+c_theme)
	for i_theme in Globals.themes.value.keys():
		if i_theme != "Default":
			themes_button.add_item(i_theme)
	ThemeLoader.load_theme(Globals.themes.get_at("Default"))
	
	await SaveManager.load_save()
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)

	if not DirAccess.dir_exists_absolute(backups_dir):
		DirAccess.make_dir_absolute(backups_dir)
	_reload_worlds()
	_reload_abilities()
	_reload_items()
	Globals.groups.reactive_changed.connect(func(_reactive):
		_refresh_groups()
		)
	Globals.groups.manually_emit()

func does_option_exist_by_text(ob: OptionButton, text: String) -> bool:
	for i in range(ob.get_item_count()):
		if ob.get_item_text(i) == text: return true
	return false


func _refresh_groups():
	if not does_option_exist_by_text(%GroupFilter,"NoFilter"):
		%GroupFilter.add_item("NoFilter")
	if not does_option_exist_by_text(%GroupFilter,"NoGroup"):
		%GroupFilter.add_item("NoGroup")
	var groups:Array=[]
	for c:Character in Globals.characters.value:
		if not groups.has(c.group.value):
			groups.append(c.group.value)
	for group:String in Globals.groups.value:
		if group != "":
			if groups.has(group):
				if not does_option_exist_by_text(%GroupFilter,group):
					%GroupFilter.add_item(group)
			else:
				for i in range(%GroupFilter.get_item_count()):
					if %GroupFilter.get_item_text(i) == group:
						%GroupFilter.remove_item(i)
				Globals.groups.erase(group)
func _reload_abilities():
	for c in ability_grid.get_children():
		c.queue_free()
	for a:String in Globals.abilities.value.keys():
		var ability:AbilityTemplate = ABILITY_TEMPLATE.instantiate()
		ability.ability_id = a
		ability_grid.add_child(ability)
		ability.delete.connect(delete_ability)
		ability.ability_use_button.disabled = true
func _reload_items():
	for c in item_grid.get_children():
		c.queue_free()
	for i:String in Globals.items.value.keys():
		var item:ItemTemplate = ITEM_TEMPLATE.instantiate()
		item.item_id = i
		item_grid.add_child(item)
		item.delete.connect(delete_item)
#region Backup
func _on_backup_pressed() -> void:
	SaveManager.start_save_thread()
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
func _open_window(title_text: String, menu_scene: PackedScene, setup: Callable) -> void:
	var window = Window.new()
	window.content_scale_size = get_viewport_rect().size
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	window.title = title_text
	var menu = menu_scene.instantiate()
	setup.call(menu)
	windows.add_child(window)
	window.add_child(menu)
#region Character Management

func _reload_characters(characters: Array) -> void:
	_refresh_groups()
	var existing_panels = character_grid.get_children()
	var needed = characters.size()

# 1. Remove excess panels (back to front to avoid index issues)
	while existing_panels.size() > needed:
		var panel = existing_panels.pop_back()
	# Clean up connections to prevent duplicates / leaks
		if panel.deleted.is_connected(SaveManager.start_save_thread):
			panel.deleted.disconnect(SaveManager.start_save_thread)
		if panel.open_character.is_connected(open_character):
			panel.open_character.disconnect(open_character)
		panel.queue_free()

# 2. Reuse existing or create new ones — connect only on creation
	for i in characters.size():
		var ch: Character = characters[i]
		var panel: CharacterTemplate
		
		if i < existing_panels.size():
			panel = existing_panels[i] as CharacterTemplate
		else:
			panel = CHARACTER_TEMPLATE.instantiate()
			character_grid.add_child(panel)
			# Connect signals **only once** when the panel is newly created
		if not panel.deleted.is_connected(SaveManager.start_save_thread):
			panel.deleted.connect(SaveManager.start_save_thread)
		if not panel.open_character.is_connected(open_character):
			panel.open_character.connect(open_character)
	# Always update the data
		panel.character = ch
	
	# Update visibility based on search (using .is_empty() is cleaner)
		panel.visible = (
		ch.name.value.to_lower().contains(%CharacterSearch.text.to_lower())
		or %CharacterSearch.text.is_empty())and(ch.group.value==%GroupFilter.text or %GroupFilter.get_selected_id()==0 or (%GroupFilter.get_selected_id()==1 and ch.group.value==""))
	
	# Refresh visuals — only call if you really need it every time
		panel.refresh_visuals()

	# Optional: ask FlowContainer to re-sort / re-flow once at the end
	character_grid.queue_sort()
	
	amount.text = "Current Amount: " + str(characters.size())

func open_character(character:Character):
	print("opening " + character.name.value)
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
		window.title = character.name.value
		window.add_child(menu)

func _sort_characters() -> void:
	var char_dict: Dictionary[String,Character]
	for c:Character in Globals.characters.value:
		char_dict[c.name.value] = c
	char_dict.sort()
	Globals.characters.value = char_dict.values()
#endregion

#region World Management

func _reload_worlds() -> void:
	_refresh_groups()
	var existing_panels = world_grid.get_children()
	var needed = Globals.worlds.value.size()
	
	# 1. Remove excess panels (back to front to avoid index issues)
	while existing_panels.size() > needed:
		var panel = existing_panels.pop_back()
		# Clean up connections to prevent duplicates / leaks
		if panel.deleted.is_connected(SaveManager.start_save_thread):
			panel.deleted.disconnect(SaveManager.start_save_thread)
		if panel.open_world.is_connected(open_world):
			panel.open_world.disconnect(open_world)
		panel.queue_free()
	
	# 2. Reuse existing or create new ones — connect only on creation
	for i in Globals.worlds.value.size():
		var ch: World = Globals.worlds.get_at(i)
		var panel: WorldTemplate
		
		if i < existing_panels.size():
			panel = existing_panels[i] as WorldTemplate
		else:
			panel = WORLD_TEMPLATE.instantiate()
			world_grid.add_child(panel)
			# Connect signals **only once** when the panel is newly created
		if not panel.deleted.is_connected(SaveManager.start_save_thread):
			panel.deleted.connect(SaveManager.start_save_thread)
		if not panel.open_world.is_connected(open_world):
			panel.open_world.connect(open_world)
		# Always update the data
		panel.world = ch
		
		# Update visibility based on search (using .is_empty() is cleaner)
		panel.visible = (
		ch.name.to_lower().contains(%WorldSearch.text.to_lower())
		or %WorldSearch.text.is_empty())
		
		# Refresh visuals — only call if you really need it every time
		panel.refresh_visuals()
	
	# Optional: ask FlowContainer to re-sort / re-flow once at the end
	world_grid.queue_sort()
	

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
	for c:World in Globals.worlds:
		world_dict[c.name] = c
	world_dict.sort()
	Globals.worlds.value = world_dict.values()
#endregion

#region Character/World Creation

#region Character Create
func _on_button_pressed() -> void:
	name_select.show()
	character_create.show()
	name_line.text = ""
	var image_texture = ImageTexture.new()
	image_texture.set_image(load("res://icons/default.png"))
	image_text.texture = image_texture
	new_image = ""

func _on_submit_image_pressed() -> void:
	image_select.hide()
	character_create.hide()
	var c = Character.new(new_name,new_image)
	Globals.characters.append(c)
	_sort_characters()
	amount.text = "Current Amount:"+str(Globals.characters.value.size())
	SaveManager.start_save_thread()

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
	Globals.worlds.append(c)
	_sort_worlds()
	Globals.world.deleted.connect(SaveManager.start_save_thread)
	SaveManager.start_save_thread()

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
	image = Globals.center_crop(image)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	image_text.texture = image_texture
	world_image_text.texture = image_texture
	new_image = path

#endregion

#region Saving/Loading
#endregion

func _exit_tree() -> void:
	SaveManager.start_save_thread()
	SaveManager.thread.wait_to_finish()


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
	print ("test")
	if Globals.themes.get_at(option) is String:
		print("ran:"+Globals.themes.get_at(option))
		ThemeLoader.load_theme(Globals.themes.get_at(option))
	else:
		get_tree().root.theme = Globals.themes.get_at(option)


func _on_tab_container_tab_changed(tab: int) -> void:
	if tab_container:
		match tab:
			0: pass  # characters handled reactively
			1: _reload_worlds()
			2: _reload_abilities(); _reload_items()


func _on_new_ability_pressed() -> void:
	ability_create.show()


func _on_submit_ability_name_pressed() -> void:
	var new_ability = Ability.new()
	new_ability.name = ability_name_line.text
	Globals.abilities.set(new_ability.name,new_ability)
	ability_create.hide()
	_reload_abilities()
	SaveManager.start_save_thread()

func delete_ability(ability_id):
	Globals.abilities.erase(ability_id)

func _on_new_item_pressed() -> void:
	item_create.show()

func _on_submit_item_name_pressed() -> void:
	var new_item = Item.new()
	new_item.name = item_name_line.text
	Globals.items.set(new_item.name,new_item)
	item_create.hide()
	_reload_items()
	SaveManager.start_save_thread()

func delete_item(item_id):
	Globals.items.erase(item_id)
