class_name Character
extends Resource

var image_path:String
var name:String
var description:String = ""
var pronouns:String = ""
var race:String = ""
var gallery_images:Array[String]
var mana:int = 0
var max_mana:int = 0
var abilities:Array[Ability]
var items:Array[Item]
var notes:Array[Note]
var open:bool = false
func _init(name_val:String,new_image_path:String) -> void:
	name = name_val
	image_path = new_image_path

func save() -> Dictionary:
	var ability_dict:Dictionary
	for ability:Ability in abilities:
		var ability_data = ability.save()
		ability_dict.set(ability.name,ability_data)
	var item_dict:Dictionary
	for item:Item in items:
		var item_data = item.save()
		item_dict.set(item.name,item_data)
	var note_dict:Dictionary
	for note:Note in notes:
		var note_data = note.save()
		note_dict.set(note.title,note_data)
	var save_dict = {
		"name" : name,
		"image_path" : image_path,
		"mana" : mana,
		"max_mana" : max_mana,
		"description":description,
		"pronouns":pronouns,
		"race":race,
		"gallery_images": gallery_images,
		"abilities" : ability_dict,
		"items": item_dict,
		"notes": note_dict
	}
	return save_dict
static func from_date(data:Dictionary)->Character:
	var character = Character.new(data.get("name"),data.get("image_path"))
	character.mana = data.get("mana")
	character.max_mana = data.get("max_mana")
	character.description = data.get_or_add("description","")
	character.pronouns = data.get_or_add("pronouns","")
	character.race = data.get_or_add("race","")
	
	var image_list:Array[String]
	for image in data.get_or_add("gallery_images",[]):
		image_list.append(image)
	character.gallery_images = image_list
	
	var ability_list:Array[Ability]
	for ability in data.get_or_add("abilities",{}).keys():
		var new_ability:Ability = Ability.new()
		new_ability.name = ability
		new_ability.description = data.get("abilities").get(ability)\
		.get("description")
		new_ability.mana_cost = data.get("abilities").get(ability)\
		.get("mana_cost")
		ability_list.append(new_ability)
	character.abilities = ability_list
	var note_list:Array[Note]
	for note in data.get_or_add("notes",{}).keys():
		var new_note:Note = Note.new()
		new_note.text = data.get("notes").get(note)\
		.get("text")
		note_list.append(new_note)
	character.notes = note_list
	var item_list:Array[Item]
	for item in data.get_or_add("items",{}).keys():
		var new_item:Item = Item.new()
		new_item.name = item
		new_item.description = data.get("items").get(item)\
		.get("description")
		item_list.append(new_item)
	character.items = item_list
	
	return character
