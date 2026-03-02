extends VBoxContainer
signal delete_note(note:Note)
const NOTE_TEMPLATE = preload("uid://dnlgwise5jnbd")

func reload_notes(array:Array):
	for c in get_children():
		c.queue_free()
	for note in array:
		var tmp:NoteTemplate=NOTE_TEMPLATE.instantiate()
		tmp.note = note
		tmp.delete_note.connect(func(_note):delete_note.emit(_note))
		add_child(tmp)
