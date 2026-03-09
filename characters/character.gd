class_name Character
extends Reactive

var image_path:ReactiveString = ReactiveString.new("",self)
var name:ReactiveString = ReactiveString.new("",self)
var description:ReactiveString = ReactiveString.new("",self)
var pronouns:ReactiveString = ReactiveString.new("",self)
var race:ReactiveString = ReactiveString.new("",self)
var gallery_images:ReactiveArray = ReactiveArray.new([],self)
var mana:ReactiveInt = ReactiveInt.new(0,self)
var max_mana:ReactiveInt = ReactiveInt.new(0,self)
var ability_ids:ReactiveArray = ReactiveArray.new([],self)
var item_ids:ReactiveArray = ReactiveArray.new([],self)
var notes:ReactiveArray = ReactiveArray.new([],self)
var open:bool = false
func _init(name_val:String,new_image_path:String) -> void:
	name.value = name_val
	image_path.value = new_image_path

func save() -> Dictionary:
	var note_dict:Dictionary
	for note:Note in notes.value:
		var note_data = note.save()
		note_dict.set(note.title.value,note_data)
	var save_dict = {
		"name" : name.value,
		"image_path" : image_path.value,
		"mana" : mana.value,
		"max_mana" : max_mana.value,
		"description":description.value,
		"pronouns":pronouns.value,
		"race":race.value,
		"gallery_images": gallery_images.value,
		"ability_ids" : ability_ids.value,
		"item_ids": item_ids.value,
		"notes": note_dict
	}
	return save_dict
static func from_data(data:Dictionary)->Character:
	var character = Character.new(data.get("name"),data.get("image_path"))
	character.mana.value = data.get("mana")
	character.max_mana.value = data.get("max_mana")
	character.description.value = data.get_or_add("description","")
	character.pronouns.value = data.get_or_add("pronouns","")
	character.race.value = data.get_or_add("race","")
	
	var image_list:Array[String]
	for image in data.get_or_add("gallery_images",[]):
		image_list.append(image)
	character.gallery_images.value = image_list
	
	for ability in data.get_or_add("abilities",{}).keys():
		var new_ability:Ability = Ability.new()
		new_ability.name.value = ability
		new_ability.description.value = data.get("abilities").get(ability)\
		.get("description")
		new_ability.mana_cost.value = data.get("abilities").get(ability)\
		.get("mana_cost")
		character.ability_ids.append(ability)
		Globals.abilities.set_at(ability,new_ability)
	character.ability_ids.append_array(data.get_or_add("ability_ids",[]))
	var note_list:Array[Note]
	for note in data.get_or_add("notes",{}).keys():
		var new_note:Note = Note.new()
		new_note.title.value = data.get("notes").get(note)\
		.get("title")
		new_note.text.value = data.get("notes").get(note)\
		.get("text")
		note_list.append(new_note)
	character.notes.value = note_list
	for item in data.get_or_add("items",{}).keys():
		var new_item:Item = Item.new()
		new_item.name.value = item
		new_item.description.value = data.get("items").get(item)\
		.get("description")
		character.item_ids.append(item)
		Globals.items.set_at(item,new_item)
		print(Globals.items.value)
	character.item_ids.append_array(data.get_or_add("item_ids",[]))
	return character
