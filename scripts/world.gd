class_name World
extends Resource

var rooms:Array[Room]=[]
var image_path:String
var world_map_path:String
var name:String
var description:String = ""
var history:String = ""
var open:bool = false
func _init(name_val:String,new_image_path:String) -> void:
	name = name_val
	image_path = new_image_path

func save() -> Dictionary:
	var room_array:Array
	for room:Room in rooms:
		var room_data = room.save()
		room_array.append(room_data)
	var save_dict = {
		"name" : name,
		"image_path" : image_path,
		"world_map_path" : world_map_path,
		"description":description,
		"history":history,
		"room_data":room_array
	}
	return save_dict
static func from_date(data:Dictionary)->World:
	var world = World.new(data.get("name"),data.get("image_path"))
	world.description = data.get_or_add("description","")
	world.history = data.get_or_add("history","")
	world.world_map_path = data.get_or_add("world_map_path","")
	for room in data.get("room_data",[]):
		var new_room = Room.load_from_data(room)
		world.rooms.append(new_room)
	return world
