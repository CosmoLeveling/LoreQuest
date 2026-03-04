extends Node


const DEFAULT_THEME_PATH := "res://themes/Default.json"

signal theme_loaded

var current_theme_data: Dictionary = {}
var global_theme: Theme = Theme.new()

var colors: Dictionary = {}
var font_sizes: Dictionary = {}

var _texture_cache: Dictionary = {}


func _ready() -> void:
	load_theme(DEFAULT_THEME_PATH)


func load_theme(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("ThemeManager: Theme file not found: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("ThemeManager: Cannot open theme file: %s" % path)
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("ThemeManager: JSON parse error in %s — line %d: %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return

	current_theme_data = json.get_data()
	_texture_cache.clear()
	_build_theme()
	_apply_globally()
	emit_signal("theme_loaded")


func _build_theme() -> void:
	global_theme = Theme.new()
	_apply_colors()       # Base colors for all controls
	_apply_fonts()        # Fonts and font sizes
	_apply_styleboxes()   # StyleBoxFlat / StyleBoxTexture / StyleBoxLine
	_apply_icons()        # Control icons (arrows, etc.)
	_apply_control_colors() # Per-control color overrides — runs LAST so it wins


# ─── Texture Loading ───────────────────────────────────────────────────────────

func _load_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	if not ResourceLoader.exists(path):
		push_warning("ThemeManager: Texture not found: %s" % path)
		return null
	var tex: Texture2D = load(path)
	_texture_cache[path] = tex
	return tex


func _load_atlas_texture(path: String, region: Array) -> AtlasTexture:
	var base := _load_texture(path)
	if not base:
		return null
	var at := AtlasTexture.new()
	at.atlas = base
	at.region = Rect2(region[0], region[1], region[2], region[3])
	return at


## Resolve a texture entry which can be:
##   - a string key referencing the top-level "textures" block
##   - a direct path string: "res://ui/button.png"
##   - a dict: { "path": "res://ui/sheet.png", "region": [x, y, w, h] }
func _resolve_texture(entry) -> Texture2D:
	if entry is String:
		var textures: Dictionary = current_theme_data.get("textures", {})
		if textures.has(entry):
			return _resolve_texture(textures[entry])
		return _load_texture(entry)
	elif entry is Dictionary:
		if entry.has("region") and entry.has("path"):
			return _load_atlas_texture(entry["path"], entry["region"])
		elif entry.has("path"):
			return _load_texture(entry["path"])
	return null


# ─── Colors ────────────────────────────────────────────────────────────────────

func _apply_colors() -> void:
	colors.clear()
	var data: Dictionary = current_theme_data.get("colors", {})
	for key in data:
		colors[key] = Color(data[key])

	var font_color     : Color = colors.get("on_background", Color.WHITE)
	var on_primary     : Color = colors.get("on_primary",    Color.WHITE)
	var disabled_color := Color(font_color.r, font_color.g, font_color.b, 0.4)

	# Note: Label is intentionally excluded here so control_colors can set it freely
	for control_type in ["Button", "LineEdit", "OptionButton",
						  "CheckBox", "CheckButton", "RichTextLabel", "TextEdit"]:
		global_theme.set_color("font_color", control_type, font_color)

	for control_type in ["Button", "OptionButton", "CheckBox", "CheckButton"]:
		global_theme.set_color("font_pressed_color",  control_type, on_primary)
		global_theme.set_color("font_hover_color",    control_type, on_primary)
		global_theme.set_color("font_disabled_color", control_type, disabled_color)

	var selection_color : Color = colors.get("primary", Color.WHITE)
	selection_color.a = 0.4
	for control_type in ["LineEdit", "TextEdit"]:
		global_theme.set_color("selection_color",        control_type, selection_color)
		global_theme.set_color("font_selected_color",    control_type, font_color)
		global_theme.set_color("caret_color",            control_type, font_color)
		global_theme.set_color("font_placeholder_color", control_type,
			Color(font_color.r, font_color.g, font_color.b, 0.6))


# ─── Per-Control Colors ────────────────────────────────────────────────────────
## Runs after _apply_colors so these values always win.
## "control_colors": {
##   "Label": { "font_color": "#ffffff" },
##   "TabBar": {
##     "font_selected_color":   "#c4a7e7",
##     "font_unselected_color": "#908caa"
##   }
## }

func _apply_control_colors() -> void:
	var data: Dictionary = current_theme_data.get("control_colors", {})
	for control_type in data:
		var props: Dictionary = data[control_type]
		for color_name in props:
			global_theme.set_color(color_name, control_type, Color(props[color_name]))


# ─── Fonts ─────────────────────────────────────────────────────────────────────

func _apply_fonts() -> void:
	font_sizes.clear()
	var size_data: Dictionary = current_theme_data.get("font_sizes", {})
	for key in size_data:
		font_sizes[key] = int(size_data[key])

	var font_data: Dictionary = current_theme_data.get("fonts", {})
	var base_size: int = font_sizes.get("base", 14)

	# Default font applied to all common controls
	if font_data.has("default") and ResourceLoader.exists(font_data["default"]):
		var font: FontFile = load(font_data["default"])
		for control_type in ["Button", "LineEdit", "OptionButton",
							  "CheckBox", "CheckButton", "RichTextLabel", "TextEdit",
							  "TabContainer", "TabBar"]:
			global_theme.set_font("font", control_type, font)
			global_theme.set_font_size("font_size", control_type, base_size)

	# Label-specific font (overrides default for Label only)
	if font_data.has("label") and ResourceLoader.exists(font_data["label"]):
		var label_font: FontFile = load(font_data["label"])
		global_theme.set_font("font", "Label", label_font)
		global_theme.set_font_size("font_size", "Label", base_size)
	elif font_data.has("default") and ResourceLoader.exists(font_data["default"]):
		# Fall back to default font for Label if no label-specific one set
		var font: FontFile = load(font_data["default"])
		global_theme.set_font("font", "Label", font)
		global_theme.set_font_size("font_size", "Label", base_size)

	if font_data.has("bold") and ResourceLoader.exists(font_data["bold"]):
		var bold_font: FontFile = load(font_data["bold"])
		global_theme.set_font("bold_font", "RichTextLabel", bold_font)

	if font_data.has("mono") and ResourceLoader.exists(font_data["mono"]):
		var mono_font: FontFile = load(font_data["mono"])
		global_theme.set_font("normal_font", "CodeEdit", mono_font)
		global_theme.set_font_size("normal_font_size", "CodeEdit", font_sizes.get("sm", 12))


# ─── Styleboxes ────────────────────────────────────────────────────────────────

func _apply_styleboxes() -> void:
	var data: Dictionary = current_theme_data.get("styleboxes", {})
	for control_type in data:
		var states: Dictionary = data[control_type]
		for state_name in states:
			var props: Dictionary = states[state_name]
			var sb: StyleBox

			if control_type in ["HSeparator", "VSeparator"]:
				sb = _build_stylebox_line(props, control_type == "VSeparator")
			elif props.get("type", "flat") == "texture":
				sb = _build_stylebox_texture(props)
			elif props.get("type", "flat") == "empty":
				sb = StyleBoxEmpty.new()
			else:
				sb = _build_stylebox_flat(props)

			if sb:
				global_theme.set_stylebox(state_name, control_type, sb)


func _build_stylebox_flat(props: Dictionary) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if props.has("bg_color"):
		sb.bg_color = Color(props["bg_color"])
	if props.has("border_color"):
		sb.border_color = Color(props["border_color"])
	if props.has("border_width"):
		var bw: int = int(props["border_width"])
		sb.border_width_left   = bw
		sb.border_width_right  = bw
		sb.border_width_top    = bw
		sb.border_width_bottom = bw
	if props.has("corner_radius"):
		var cr: int = int(props["corner_radius"])
		sb.corner_radius_top_left     = cr
		sb.corner_radius_top_right    = cr
		sb.corner_radius_bottom_left  = cr
		sb.corner_radius_bottom_right = cr
	if props.has("content_margin"):
		var m: Array = props["content_margin"]
		if m.size() == 4:
			sb.content_margin_left   = float(m[0])
			sb.content_margin_top    = float(m[1])
			sb.content_margin_right  = float(m[2])
			sb.content_margin_bottom = float(m[3])
	return sb


func _build_stylebox_line(props: Dictionary, vertical := false) -> StyleBoxLine:
	var sb := StyleBoxLine.new()
	if props.has("bg_color"):
		sb.color = Color(props["bg_color"])
	sb.thickness  = int(props.get("thickness",   1))
	sb.grow_begin = float(props.get("grow_begin", 0.0))
	sb.grow_end   = float(props.get("grow_end",   0.0))
	sb.vertical   = vertical
	return sb


## "type": "texture"
## "texture": "named_key" | "res://path.png" | { "path": "...", "region": [x,y,w,h] }
## "margins": [left, top, right, bottom]
## "expand_margins": [left, top, right, bottom]
## "content_margin": [left, top, right, bottom]
func _build_stylebox_texture(props: Dictionary) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	if props.has("texture"):
		var tex := _resolve_texture(props["texture"])
		if tex:
			sb.texture = tex
	if props.has("margins"):
		var m: Array = props["margins"]
		if m.size() == 4:
			sb.texture_margin_left   = float(m[0])
			sb.texture_margin_top    = float(m[1])
			sb.texture_margin_right  = float(m[2])
			sb.texture_margin_bottom = float(m[3])
	if props.has("expand_margins"):
		var m: Array = props["expand_margins"]
		if m.size() == 4:
			sb.expand_margin_left   = float(m[0])
			sb.expand_margin_top    = float(m[1])
			sb.expand_margin_right  = float(m[2])
			sb.expand_margin_bottom = float(m[3])
	if props.has("content_margin"):
		var m: Array = props["content_margin"]
		if m.size() == 4:
			sb.content_margin_left   = float(m[0])
			sb.content_margin_top    = float(m[1])
			sb.content_margin_right  = float(m[2])
			sb.content_margin_bottom = float(m[3])
	return sb


# ─── Icons ─────────────────────────────────────────────────────────────────────
## "icons": {
##   "OptionButton": { "arrow": "named_key_or_path" },
##   "SpinBox": {
##     "up": { "path": "res://ui/arrows.png", "region": [0, 2, 12, 8] }, ...
##   }
## }

func _apply_icons() -> void:
	var data: Dictionary = current_theme_data.get("icons", {})
	for control_type in data:
		var icon_map: Dictionary = data[control_type]
		for icon_name in icon_map:
			var tex := _resolve_texture(icon_map[icon_name])
			if tex:
				global_theme.set_icon(icon_name, control_type, tex)


# ─── Global Application ────────────────────────────────────────────────────────

func _apply_globally() -> void:
	get_tree().root.theme = global_theme


# ─── Local Theme (no global apply) ────────────────────────────────────────────

func load_theme_local(path: String) -> Theme:
	if not FileAccess.file_exists(path):
		push_error("ThemeManager: Theme file not found: %s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("ThemeManager: JSON parse error in %s — line %d: %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return null

	var saved_data       := current_theme_data.duplicate(true)
	var saved_colors     := colors.duplicate()
	var saved_font_sizes := font_sizes.duplicate()

	current_theme_data = json.get_data()
	_build_theme()
	var result := global_theme

	current_theme_data = saved_data
	colors             = saved_colors
	font_sizes         = saved_font_sizes
	_build_theme()

	return result


# ─── Public Helpers ────────────────────────────────────────────────────────────

func get_color(_name: String, fallback := Color.WHITE) -> Color:
	return colors.get(_name, fallback)

func get_font_size(_name: String, fallback := 14) -> int:
	return font_sizes.get(_name, fallback)

func switch_theme(path: String) -> void:
	load_theme(path)
