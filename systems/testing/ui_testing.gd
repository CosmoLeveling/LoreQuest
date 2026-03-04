extends Control

var v:ReactiveString=ReactiveString.new("")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ThemeLoader.load_theme("res://themes/Rosepine.json")
	%LineEdit.text_changed.connect(func(text):v.value=text)
	%LineEdit2.text_changed.connect(func(text):v.value=text)
	v.reactive_changed.connect(func(reactive):
		if %LineEdit.text != reactive.value:
			%LineEdit.text = reactive.value
		if %LineEdit2.text != reactive.value:
			%LineEdit2.text = reactive.value
		)
		
	
