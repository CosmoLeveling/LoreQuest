@tool
extends Node2D
@onready var camera_2d: Camera2D = $"../Camera2D"

# Defaults — overridden by ThemeManager if available
var GRID_SIZE := 40
var GRID_COLOR := Color(1.0, 0.643, 0.212, 0.478)
var BACKGROUND_COLOR := Color("561a29")
var MAJOR_LINE_EVERY := 5
var MAJOR_COLOR := Color(1.0, 0.643, 0.212, 1.0)
var AXIS_COLOR := Color(0.8, 0.285, 0.0, 1.0)


func _ready() -> void:
	_load_theme()


func _load_theme() -> void:
	# Gracefully skip if ThemeManager isn't present (e.g. in @tool mode in editor)

	var grid: Dictionary = ThemeLoader.current_theme_data.get("grid", {})
	if grid.is_empty():
		return

	if grid.has("grid_size"):
		GRID_SIZE = int(grid["grid_size"])
	if grid.has("background_color"):
		BACKGROUND_COLOR = Color(grid["background_color"])
	if grid.has("minor_color"):
		GRID_COLOR = Color(grid["minor_color"])
	if grid.has("major_color"):
		MAJOR_COLOR = Color(grid["major_color"])
	if grid.has("axis_color"):
		AXIS_COLOR = Color(grid["axis_color"])
	if grid.has("major_line_every"):
		MAJOR_LINE_EVERY = int(grid["major_line_every"])

	queue_redraw()


func _draw():
	_load_theme()
	var viewport_size = get_viewport_rect().size
	var half_w = (viewport_size.x / 2) / camera_2d.zoom.x
	var half_h = (viewport_size.y / 2) / camera_2d.zoom.y
	var top_left = camera_2d.position - Vector2(half_w, half_h)
	var bottom_right = camera_2d.position + Vector2(half_w, half_h)
	draw_rect(Rect2(top_left, bottom_right - top_left), BACKGROUND_COLOR)
	draw_grid()
	draw_origin()


func draw_origin():
	var origin_size = 10 / camera_2d.zoom.x
	var origin_color = AXIS_COLOR
	# Horizontal line
	draw_line(
		Vector2(-origin_size, 0),
		Vector2(origin_size, 0),
		origin_color,
		2 / camera_2d.zoom.x
	)
	# Vertical line
	draw_line(
		Vector2(0, -origin_size),
		Vector2(0, origin_size),
		origin_color,
		2 / camera_2d.zoom.x
	)


func draw_grid():
	var view_size = get_viewport_rect().size
	var cam_pos = camera_2d.position
	var zoom = camera_2d.zoom.x  # assume uniform zoom
	# Compute visible world bounds, taking zoom into account
	var half_w = (view_size.x / 2) / zoom
	var half_h = (view_size.y / 2) / zoom
	var left = cam_pos.x - half_w
	var right = cam_pos.x + half_w
	var top = cam_pos.y - half_h
	var bottom = cam_pos.y + half_h
	# Snap starting positions to multiples of GRID_SIZE
	var start_x = floor(left / GRID_SIZE) * GRID_SIZE
	var start_y = floor(top / GRID_SIZE) * GRID_SIZE
	# Draw vertical lines
	var x = start_x
	var line_index = int(start_x / GRID_SIZE)
	while x <= right:
		var color = GRID_COLOR
		var thickness = 1.0 / zoom
		if line_index % MAJOR_LINE_EVERY == 0:
			color = MAJOR_COLOR
			thickness *= 2
		if line_index == 0:
			color = AXIS_COLOR
			thickness *= 2
		draw_line(Vector2(x, top), Vector2(x, bottom), color, thickness)
		x += GRID_SIZE
		line_index += 1
	# Draw horizontal lines
	var y = start_y
	line_index = int(start_y / GRID_SIZE)
	while y <= bottom:
		var color = GRID_COLOR
		var thickness = 1.0 / zoom
		if line_index % MAJOR_LINE_EVERY == 0:
			color = MAJOR_COLOR
			thickness *= 2
		if line_index == 0:
			color = AXIS_COLOR
			thickness *= 2
		draw_line(Vector2(left, y), Vector2(right, y), color, thickness)
		y += GRID_SIZE
		line_index += 1
