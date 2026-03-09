extends Node

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

	return json.data

# Save character data to a file.
func save_characters(characters: Array):
	var data = []
	for character in characters:
		if character.has_method("save"):
			data.append(character.save())
	write_save_file(SAVE_DIR + "characters.save", {"characters": data})

# Load character data from a file.
func load_characters() -> Array:
	var save_data = read_save_file(SAVE_DIR + "characters.save")
	var characters = []
	if "characters" in save_data:
		for char_data in save_data["characters"]:
			characters.append(Character.from_data(char_data))
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

