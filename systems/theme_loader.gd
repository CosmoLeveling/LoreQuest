extends Node
class_name ThemeLoader

# --------------------------------------------------
# PUBLIC API
# --------------------------------------------------

static func load_theme(path: String) -> Theme:
	var data: Dictionary = _load_json(path)
	return _build_theme(data)

# --------------------------------------------------
# FILE LOADING
# --------------------------------------------------

static func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open theme file: %s" % path)
		return {}

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON theme file: %s" % path)
		return {}

	return parsed as Dictionary

# --------------------------------------------------
# THEME BUILDING
# --------------------------------------------------

static func _build_theme(data: Dictionary) -> Theme:
	var theme := Theme.new()

	var colors: Dictionary = data.get("colors", {})
	var fonts: Dictionary = data.get("fonts", {})
	var radius: Dictionary = data.get("radius", {})
	var spacing: Dictionary = data.get("spacing", {})

	var col_bg: Color = _col(colors, "background", "#000000")
	var col_panel: Color = _col(colors, "panel", "#202020")
	var col_panel_alt: Color = _col(colors, "panel_alt", "#2a2a2a")
	var col_border: Color = _col(colors, "border", "#404040")
	var col_text: Color = _col(colors, "text", "#ffffff")
	var col_text_muted: Color = _col(colors, "text_muted", "#aaaaaa")
	var col_selection: Color = _col(colors, "selection", "#444444")

	var font := FontFile.new()
	if fonts.has("ui"):
		font = load(fonts["ui"])

	theme.default_font = font
	theme.default_font_size = int(fonts.get("size_normal", 16))

	var radius_small: int = int(radius.get("small", 2))
	var radius_medium: int = int(radius.get("medium", 4))
	var padding: int = int(spacing.get("padding", 6))

	# Panels
	theme.set_stylebox(
		"panel",
		"Panel",
		_panel_box(col_panel, col_border, radius_medium, padding)
	)
	theme.set_stylebox(
		"panel",
		"PanelContainer",
		_panel_box(col_panel, col_border, radius_medium, padding)
	)
	# Labels
	theme.set_color("font_color", "Label", col_text)

	# Buttons
	theme.set_stylebox(
		"normal",
		"Button",
		_button_box(col_panel, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"hover",
		"Button",
		_button_box(col_panel_alt, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"pressed",
		"Button",
		_button_box(col_selection, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"panel",
		"Root",
		_panel_box(col_bg, Color.TRANSPARENT, 0, 0)
	)
	theme.set_color("font_color", "Button", col_text)
	theme.set_color("font_disabled_color", "Button", col_text_muted)

	theme.set_stylebox(
		"panel",
		"TabContainer",
		_panel_box(col_panel, col_border, radius_medium, padding)
	)
	theme.set_stylebox(
		"tab_unselected",
		"TabContainer",
		_button_box(col_panel, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"tab_selected",
		"TabContainer",
		_button_box(col_selection, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"tab_hover",
		"TabContainer",
		_button_box(col_panel_alt, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"tab_focus",
		"TabContainer",
		_button_box(col_panel_alt, col_border, radius_small, padding)
	)
	theme.set_stylebox(
		"separator",
		"HSeparator",
		_line_style(col_border,padding)
	)
	# LineEdit
	theme.set_stylebox(
		"normal",
		"LineEdit",
		_panel_box(col_panel, col_border, radius_small, padding)
	)
	theme.set_color("font_color", "LineEdit", col_text)
	theme.set_color("selection_color", "LineEdit", col_selection)
	
	return theme

# --------------------------------------------------
# STYLEBOX HELPERS
# --------------------------------------------------

static func _panel_box(
	bg: Color,
	border: Color,
	radius: int,
	padding: int
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_bottom = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_left = 1
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_left = padding
	sb.content_margin_right = padding
	sb.content_margin_top = padding
	sb.content_margin_bottom = padding
	return sb

static func _line_style(
	bg: Color,
	padding: int
) -> StyleBoxLine:
	var sb := StyleBoxLine.new()
	sb.color = bg
	sb.thickness = 1
	sb.content_margin_left = padding
	sb.content_margin_right = padding
	sb.content_margin_top = padding
	sb.content_margin_bottom = padding
	return sb


static func _button_box(
	bg: Color,
	border: Color,
	radius: int,
	padding: int
) -> StyleBoxFlat:
	return _panel_box(bg, border, radius, padding)


# --------------------------------------------------
# UTIL
# --------------------------------------------------

static func _col(dict: Dictionary, key: String, fallback: String) -> Color:
	if dict.has(key):
		return Color.html(str(dict[key]))
	return Color.html(fallback)
