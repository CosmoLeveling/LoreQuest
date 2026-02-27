extends Control
@onready var ability_box: VBoxContainer = $"MarginContainer/HBoxContainer/TabContainer/Items&Abilities/Abilities/VBoxContainer/ScrollContainer/AbilityBox"
@onready var item_box: VBoxContainer = $"MarginContainer/HBoxContainer/TabContainer/Items&Abilities/Items/VBoxContainer/ScrollContainer/ItemBox"
@onready var mana_spin_box: SpinBox = $"MarginContainer/HBoxContainer/TabContainer/Items&Abilities/Abilities/VBoxContainer/HBoxContainer/ManaSpinBox"
@onready var gallery_file_dialog: FileDialog = $GalleryFileDialog
@onready var file_dialog: FileDialog = $FileDialog
@onready var avatar: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Avatar
@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Name
@onready var max_mana_spin_box: SpinBox = $"MarginContainer/HBoxContainer/TabContainer/Items&Abilities/Abilities/VBoxContainer/HBoxContainer/MaxManaSpinBox"
@onready var description: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Description
@onready var race: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Race
@onready var pronouns: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Pronouns
@onready var name_change: CenterContainer = $NameChange
@onready var name_line: LineEdit = $NameChange/NameSelect/MarginContainer/VBoxContainer/NameLine
@onready var gallery_grid: GridContainer = $MarginContainer/HBoxContainer/TabContainer/Gallery/Panel/VBoxContainer/ScrollContainer/CenterContainer/GalleryGrid
@onready var image_view: CenterContainer = $ImageView
@onready var image_view_texture: TextureRect = $ImageView/Panel/VBoxContainer/ImageViewTexture
@onready var notes_box: VBoxContainer = $MarginContainer/HBoxContainer/TabContainer/Notes/Panel/VBoxContainer/ScrollContainer/NotesBox
const ABILITY_TEMPLATE = preload("uid://chufft44nwvjs")
const ITEM_TEMPLATE = preload("uid://demp65srmd3xs")
const GALLERY_TEMPLATE = preload("uid://b8byq3d2opaqo")
const NOTE_TEMPLATE = preload("uid://dnlgwise5jnbd")
const AVATAR_TEMPLATE = preload("uid://b3abye6b076tm")
var character:Character
var new_ability_name:String
var new_item_name:String
@onready var ability_create: CenterContainer = $AbilityCreate
@onready var item_create: CenterContainer = $ItemCreate
func _ready() -> void:
	if character:
		var _temp:AvatarTemplate = AVATAR_TEMPLATE.instantiate()
		_temp.image_path = character.image_path
		gallery_grid.add_child(_temp)
		_temp.open_image.connect(open_avatar_image)
		for note in character.notes:
			var temp:NoteTemplate = NOTE_TEMPLATE.instantiate()
			temp.note = note
			notes_box.add_child(temp)
		for image in character.gallery_images:
			var temp:GalleryTemplate = GALLERY_TEMPLATE.instantiate()
			temp.image_path = image
			gallery_grid.add_child(temp)
			temp.open_image.connect(open_gallery_image)
			temp.deleted.connect(remove_gallery_image)
		for ability in character.abilities:
			var temp = ABILITY_TEMPLATE.instantiate()
			temp.ability = ability
			ability_box.add_child(temp)
			temp.abilityUsed.connect(use_ability)
		for item in character.items:
			var temp = ITEM_TEMPLATE.instantiate()
			temp.item = item
			item_box.add_child(temp)
		name_label.text = character.name
		var image:Image = Image.new()
		
		if FileAccess.file_exists(character.image_path):
			image.load(character.image_path)
			image = Global.center_crop(image)
		else:
			image = load("res://assets/default.png")
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		mana_spin_box.value = clampi(int(character.mana),0,character.max_mana)
		mana_spin_box.max_value = 	clampi(int(character.max_mana),0,int(character.max_mana))
		max_mana_spin_box.value = 	clampi(int(character.max_mana),0,int(character.max_mana))
		description.text = character.description
		pronouns.text = character.pronouns
		race.text = character.race
		avatar.texture = image_texture
	
func use_ability(value:int,_ability) -> void:
	if value<=character.mana:
		character.mana -= clampi(int(value),0,character.max_mana)
		mana_spin_box.value -= clampi(int(value),0,character.max_mana)

func _on_mana_spin_box_value_changed(value: float) -> void:
	character.mana = clampi(int(value),0,character.max_mana)
	mana_spin_box.value = clampi(int(value),0,character.max_mana)

func _on_max_mana_spin_box_value_changed(value: float) -> void:
	character.max_mana = clampi(int(value),0,int(value))
	character.mana = clampi(int(character.mana),0,character.max_mana)
	mana_spin_box.value = clampi(int(character.mana),0,character.max_mana)
	mana_spin_box.max_value = clampi(int(value),0,int(value))



func _on_change_image_pressed() -> void:
	file_dialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	image = Global.center_crop(image)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	avatar.texture = image_texture
	character.image_path = path


func _on_new_ability_pressed() -> void:
	ability_create.show()


func _on_save_pressed() -> void:
	get_tree().current_scene.start_save_thread()
	get_tree().current_scene._reload_characters()
	character.open = false
	get_parent().queue_free()

func _on_description_text_changed() -> void:
	character.description = description.text

func _on_race_text_changed(new_text: String) -> void:
	character.race = new_text

func _on_pronouns_text_changed(new_text: String) -> void:
	character.pronouns = new_text

func _on_ability_name_line_text_changed(new_text: String) -> void:
	new_ability_name = new_text


func _on_ability_submit_name_pressed() -> void:
	var ability = Ability.new()
	ability.name = new_ability_name
	character.abilities.append(ability)
	var temp = ABILITY_TEMPLATE.instantiate()
	temp.ability = ability
	ability_box.add_child(temp)
	temp.abilityUsed.connect(use_ability)
	ability_create.hide()


func _on_item_name_line_text_changed(new_text: String) -> void:
	new_item_name = new_text


func _on_item_submit_name_pressed() -> void:
	var item = Item.new()
	item.name = new_item_name
	character.items.append(item)
	var temp = ITEM_TEMPLATE.instantiate()
	temp.item = item
	item_box.add_child(temp)
	item_create.hide()


func _on_new_item_pressed() -> void:
	item_create.show()


func _on_rename_pressed() -> void:
	name_change.show()
	name_line.text = character.name


func _on_submit_name_pressed() -> void:
	character.name = name_line.text
	name_label.text = name_line.text
	name_change.hide()


func _on_add_gallery_image_pressed() -> void:
	gallery_file_dialog.popup()


func _on_gallery_file_dialog_file_selected(path: String) -> void:
	var new_gallery_item: GalleryTemplate = GALLERY_TEMPLATE.instantiate()
	if FileAccess.file_exists(path):
		new_gallery_item.image_path = path
	else:
		return
	character.gallery_images.append(path)
	gallery_grid.add_child(new_gallery_item)
	new_gallery_item.open_image.connect(open_gallery_image)
	new_gallery_item.deleted.connect(remove_gallery_image)
func remove_gallery_image(path:String):
	character.gallery_images.erase(path)

func open_gallery_image(path:String,gallery_image:GalleryTemplate):
	var image:Image = Image.new()
	if FileAccess.file_exists(path):
		image.load(path)
	else:
		gallery_image.queue_free()
		return
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.set_image(image)
	image_view_texture.texture = image_texture
	image_view.show()

func open_avatar_image(path:String):
	var image:Image = Image.new()
	if FileAccess.file_exists(path):
		image.load(path)
	else:
		return
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.set_image(image)
	image_view_texture.texture = image_texture
	image_view.show()

func _on_close_pressed() -> void:
	image_view.hide()

func _on_add_note_pressed() -> void:
	var note:Note = Note.new()
	character.notes.append(note)
	var new_note:NoteTemplate = NOTE_TEMPLATE.instantiate()
	new_note.note = note
	notes_box.add_child(new_note)
