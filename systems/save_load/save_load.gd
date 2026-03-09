extends Node
var current_save_version:int = 1
# The SaveLoad class is responsible for managing saving and loading operations for the application.
# This script centralizes all save/load tasks, improving modularity and code separation.

# Constants
const SAVE_DIR = "user://saves/"
const BACKUPS_DIR = "user://backups/"

# Helper function to write to a save file.
func write_save_file(path: String, data: Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()
# Helper function to read from a save file.
func read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file.get_error() != OK:
		return {}

	var json_string = file.get_as_text()
	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("Error parsing JSON from save file.")
		return {}
	file.close()
	return json.data

# Save character data to a file.
func save_characters(characters: Array):
	var data = []
	for character in characters:
		if character.has_method("save"):
			data.append(character.save())
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	write_save_file(SAVE_DIR +addon + "characters.save", {"characters": data,"save_version":current_save_version})

# Load character data from a file.
func load_characters() -> Array:
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	var save_data = read_save_file(SAVE_DIR+addon + "characters.save")
	var characters = []
	if "characters" in save_data:
		if save_data.get("save_version",0)==current_save_version:
			for char_data in save_data["characters"]:
				characters.append(Character.from_data(char_data))
		else:
			for char_data in migrate_characters(save_data.get("save_version",0)):
				characters.append(Character.from_data(char_data))
	else:
		for char_data in migrate_characters(save_data.get("save_version",0)):
			characters.append(Character.from_data(char_data))
	return characters
func migrate_characters(version:int) -> Array:
	var characters : Array = []
	var addon := ""
	if OS.is_debug_build():
		addon = "debug-"
	if version <=0:
		var save_file = FileAccess.open(SAVE_DIR+"/"+addon+"characters.save", FileAccess.READ)
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
			characters.append(node_data)
	return characters
# Save world data to a file.
func save_worlds(worlds: Array):
	var data = []
	for world in worlds:
		if world.has_method("save"):
			data.append(world.save())
	write_save_file(SAVE_DIR + "worlds.save", {"worlds": data})

# Load world data from a file.
func load_worlds() -> Array:
	var save_data = read_save_file(SAVE_DIR + "worlds.save")
	var worlds = []
	if "worlds" in save_data:
		for world_data in save_data["worlds"]:
			worlds.append(World.from_data(world_data))
	return worlds
