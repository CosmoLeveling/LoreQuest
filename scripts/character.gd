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
var ability_ids:Array
var item_ids:Array[String]
var notes:Array[Note]
var open:bool = false
func _init(name_val:String,new_image_path:String) -> void:
	name = name_val
	image_path = new_image_path

func save() -> Dictionary:
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
		"ability_ids" : ability_ids,
		"item_ids": item_ids,
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
	
	for ability in data.get_or_add("abilities",{}).keys():
		var new_ability:Ability = Ability.new()
		new_ability.name = ability
		new_ability.description = data.get("abilities").get(ability)\
		.get("description")
		new_ability.mana_cost = data.get("abilities").get(ability)\
		.get("mana_cost")
		character.ability_ids.append(ability)
		Global.abilities.set(ability,new_ability)
	character.ability_ids.append_array(data.get_or_add("ability_ids",[]))
	var note_list:Array[Note]
	for note in data.get_or_add("notes",{}).keys():
		var new_note:Note = Note.new()
		new_note.text = data.get("notes").get(note)\
		.get("text")
		note_list.append(new_note)
	character.notes = note_list
	for item in data.get_or_add("items",{}).keys():
		var new_item:Item = Item.new()
		new_item.name = item
		new_item.description = data.get("items").get(item)\
		.get("description")
		character.item_ids.append(item)
		Global.items.set(item,new_item)
	character.item_ids.append_array(data.get_or_add("item_ids",[]))
	return character
