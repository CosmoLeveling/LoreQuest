extends Node
const save_dir = "user://saves"
var thread:Thread


func _ready() -> void:
	thread = Thread.new()


func _parse_save_file(path: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if not FileAccess.file_exists(path): return results
	var file = FileAccess.open(path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json = JSON.new()
		if json.parse(file.get_line()) == OK:
			results.append(json.data)
	return results

func _get_save_path(filename: String) -> String:
	var addon = "debug-" if OS.is_debug_build() else ""
	return save_dir + "/" + addon + filename

func start_save_thread():
	if thread.is_started():
		thread.wait_to_finish()
	thread.start(save)

func load_save():
	_load_settings()
	_load_characters()
	_load_worlds()
	_load_items()
	_load_abilities()

func _load_settings() -> void:
	if not FileAccess.file_exists(_get_save_path("settings.save")):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var parsed:Array = _parse_save_file(_get_save_path("settings.save"))
	for node_data in parsed:
		if Globals.themes.has(node_data.get("theme","Default")):
			var option:String = node_data.get("theme","Default")
			if Globals.themes.get_at(option) is String:
				ThemeLoader.load_theme(Globals.themes.get_at(option))
			else:
				get_tree().root.theme = Globals.themes.get_at(option)

func _load_abilities() -> void:
	if not FileAccess.file_exists(_get_save_path("abilities.save")):
		return # Error! We don't have a save to load.
	var parsed:Array = _parse_save_file(_get_save_path("abilities.save"))
	for node_data in parsed:
		var ability:Ability = Ability.from_data(node_data)
		Globals.abilities.set_at(ability.name.value,ability)

func _load_items() -> void:
	if not FileAccess.file_exists(_get_save_path("items.save")):
		return # Error! We don't have a save to load.

	var parsed:Array = _parse_save_file(_get_save_path("items.save"))
	for node_data in parsed:
		var item:Item = Item.from_data(node_data)
		Globals.items.set_at(item.name.value,item)

func _load_characters() -> void:
	if not FileAccess.file_exists(_get_save_path("characters.save")):
		return # Error! We don't have a save to load.

	Globals.characters.clear()

	var parsed:Array = _parse_save_file(_get_save_path("characters.save"))
	for node_data in parsed:
		var character = Character.from_date(node_data)
		Globals.characters.append(character)

func _load_worlds() -> void:
	if not FileAccess.file_exists(_get_save_path("worlds.save")):
		return # Error! We don't have a save to load.

	Globals.worlds.clear()

	var parsed:Array = _parse_save_file(_get_save_path("worlds.save"))
	for node_data in parsed:
		var world = World.from_date(node_data)
		Globals.worlds.append(world)

func save():
	_save_items()
	_save_abilities()
	_save_settings()
	_save_characters()
	_save_worlds()

func _save_settings():
	var save_file = FileAccess.open(_get_save_path("settings.save"),FileAccess.WRITE)
	var data:Dictionary = {
		"theme":ThemeLoader.current_theme_data.get("name")
	}
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func _save_abilities():
	var save_file = FileAccess.open(_get_save_path("abilities.save"),FileAccess.WRITE)
	for ability in Globals.abilities.value.values():
		var json_string = JSON.stringify(ability.save())
		save_file.store_line(json_string)

func _save_items():
	var save_file = FileAccess.open(_get_save_path("items.save"),FileAccess.WRITE)
	for item in Globals.items.value.values():
		var json_string = JSON.stringify(item.save())
		save_file.store_line(json_string)

func _save_characters():
	var save_file = FileAccess.open(_get_save_path("characters.save"),FileAccess.WRITE)
	for c:Character in Globals.characters.value:
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
func _save_worlds():
	var save_file = FileAccess.open(_get_save_path("worlds.save"),FileAccess.WRITE)
	for c:World in Globals.worlds.value:
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

func _exit_tree() -> void:
	thread.wait_to_finish()
