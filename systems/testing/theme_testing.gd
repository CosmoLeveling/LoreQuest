extends Control

@onready var button_3: Button = $PanelContainer/HBoxContainer/Button3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ThemeLoader.switch_theme("user://themes/Testing.json")
