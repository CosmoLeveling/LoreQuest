extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	theme = ThemeLoader.load_theme("user://themes/test.json")
