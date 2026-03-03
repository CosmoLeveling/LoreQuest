extends Control

var character : Character = null

func _ready() -> void:
	#region character editing
	%Pronouns.text_changed.connect(func(text): character.pronouns.value=text)
	%Race.text_changed.connect(func(text): character.race.value=text)
	%Description.text_changed.connect(func(): character.description.value=%Description.text)
	%Group.text_changed.connect(func(text):
		character.group.value=%Group.text
		if not Globals.groups.value.has(%Group.text):
				Globals.groups.append(%Group.text)
		Globals.groups.manually_emit()
	)
	character.name.reactive_changed.connect(func(reactive):
		if %Name.text != reactive.value:
			%Name.text = reactive.value
		)
	character.pronouns.reactive_changed.connect(func(reactive):
		if %Pronouns.text != reactive.value:
			%Pronouns.text = reactive.value
		)
	character.race.reactive_changed.connect(func(reactive):
		if %Race.text != reactive.value:
			%Race.text = reactive.value
		)
	character.description.reactive_changed.connect(func(reactive):
		if %Description.text != reactive.value:
			%Description.text = reactive.value
		)
	character.group.reactive_changed.connect(func(reactive):
		if %Group.text != reactive.value:
			%Group.text = reactive.value
		)
	
	character.mana.reactive_changed.connect(func(reactive):
		if %ManaSpinBox.value != reactive.value:
			%ManaSpinBox.value = reactive.value
		)
	
	character.max_mana.reactive_changed.connect(func(reactive):
		if %MaxManaSpinBox.value != reactive.value:
			%MaxManaSpinBox.value = reactive.value
		)
	
	character.image_path.reactive_changed.connect(func(reactive):
		var image:Image = Image.new()
		if FileAccess.file_exists(reactive.value):
			image.load(reactive.value)
			image = Globals.center_crop(image)
		else:
			image = load("res://icons/default.png")
		
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		
		%Avatar.texture = image_texture
		)
	character.ability_ids.reactive_changed.connect(func(reactive):
		%AbilityBox.reload_abilities(reactive.value))
	character.item_ids.reactive_changed.connect(func(reactive):
		%ItemBox.reload_items(reactive.value))
	character.gallery_images.reactive_changed.connect(func(reactive):
		%GalleryGrid.reload_gallery(character,reactive.value))
	character.notes.reactive_changed.connect(func(reactive):
		%NotesBox.reload_notes(reactive.value))
	%GalleryGrid.open_gallery_image.connect(func(path):
		var image:Image = Image.new()
		if FileAccess.file_exists(path):
			image.load(path)
		else:
			character.gallery_images.erase(path)
			return
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		%ImageView.show()
		%ImageViewTexture.texture = image_texture
	)
	%GalleryGrid.open_avatar_image.connect(func(path):
		var image:Image = Image.new()
		if FileAccess.file_exists(path):
			image.load(path)
		else:
			image = load("res://icons/default.png")
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		%ImageView.show()
		%ImageViewTexture.texture = image_texture
	)
	character.name.manually_emit()
	character.mana.manually_emit()
	character.max_mana.manually_emit()
	character.image_path.manually_emit()
	character.pronouns.manually_emit()
	character.race.manually_emit()
	character.notes.manually_emit()
	character.description.manually_emit()
	character.gallery_images.manually_emit()
	character.ability_ids.manually_emit()
	character.item_ids.manually_emit()
	#endregion
	%AddGalleryImage.pressed.connect(func():%GalleryFileDialog.popup())
	%GalleryFileDialog.file_selected.connect(func(path):character.gallery_images.append(path))
	%NotesBox.delete_note.connect(func(note):character.notes.erase(note))
	%AddNote.pressed.connect(func():
		var new_note:Note = Note.new()
		character.notes.append(new_note)
		)
	%AbilityChooseGrid.ability_choosen.connect(func(id):character.ability_ids.append(id);%AbilityChoose.hide())
	%AbilityBox.ability_deleted.connect(func(id):character.ability_ids.erase(id))
	%AbilityBox.ability_used.connect(func(id):character.mana.value=max(character.mana.value-Globals.abilities.get_at(id).mana_cost.value,0))
	%ChooseAbility.pressed.connect(func():
		%AbilityChoose.show()
		%SearchAbilities.text = ""
		%AbilityChooseGrid._reload_abilities(character.ability_ids.value)
	)
	%SearchAbilities.text_changed.connect(func(text):
		%AbilityChooseGrid._reload_abilities(character.ability_ids.value,text)
		)
	%CloseAbilityChoose.pressed.connect(func():%AbilityChoose.hide())
	%NewAbility.pressed.connect(func():%AbilityCreate.show();%AbilityNameLine.text="")
	%AbilitySubmitName.pressed.connect(func():
		var id = %AbilityNameLine.text
		var new_ability:Ability=Ability.new()
		new_ability.name.value=id
		if not Globals.abilities.has(id):
			Globals.abilities.set_at(id,new_ability)
		character.ability_ids.append(id)
		%AbilityCreate.hide()
		)
	%CloseImage.pressed.connect(func():%ImageView.hide())
	
	%ItemChooseGrid.item_choosen.connect(func(id):character.item_ids.append(id);%ItemChoose.hide())
	%ItemBox.item_deleted.connect(func(id):character.item_ids.erase(id))
	%ChooseItem.pressed.connect(func():
		%ItemChoose.show()
		%SearchItems.text = ""
		%ItemChooseGrid._reload_items(character.item_ids.value)
	)
	%SearchItems.text_changed.connect(func(text):
		%ItemChooseGrid._reload_items(character.item_ids.value,text)
		)
	%CloseItemChoose.pressed.connect(func():%ItemChoose.hide())
	%NewItem.pressed.connect(func():%ItemCreate.show();%ItemNameLine.text="")
	%ItemSubmitName.pressed.connect(func():
		var id = %ItemNameLine.text
		var new_item:Item=Item.new()
		new_item.name.value=id
		if not Globals.items.has(id):
			Globals.items.set_at(id,new_item)
		character.item_ids.append(id)
		%ItemCreate.hide()
		)
	
	%ChangeImage.pressed.connect(func():%FileDialog.popup())
	%Rename.pressed.connect(func():%NameChange.show();%NameChangeLine.text=character.name.value)
	%ManaSpinBox.value_changed.connect(func(value):character.mana.value=clamp(value,0,character.max_mana.value))
	%MaxManaSpinBox.value_changed.connect(func(value):
		character.max_mana.value=value
		%ManaSpinBox.max_value = value
	)
	%SubmitName.pressed.connect(func():character.name.value = %NameChangeLine.text;%NameChange.hide())
	%FileDialog.file_selected.connect(func(path:String): character.image_path.value = path)
	

func _on_save_pressed() -> void:
	get_tree().current_scene.start_save_thread()
	character.open = false
	get_parent().queue_free()
