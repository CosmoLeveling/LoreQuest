@tool
extends Node2D
@onready var camera_2d: Camera2D = $"../Camera2D"
const GRID_SIZE := 40  # size of each cell in pixels
const GRID_COLOR := Color(1.0, 0.643, 0.212, 0.478)
const BACKGROUND_COLOR = Color("561a29")  # dark gray
const MAJOR_LINE_EVERY = 5
func _draw():
	var viewport_size = get_viewport_rect().size
	var half_w = (viewport_size.x / 2) / camera_2d.zoom.x
	var half_h = (viewport_size.y / 2) / camera_2d.zoom.y
	var top_left = camera_2d.position - Vector2(half_w, half_h)
	var bottom_right = camera_2d.position + Vector2(half_w, half_h)

	draw_rect(Rect2(top_left, bottom_right - top_left), BACKGROUND_COLOR)
	draw_grid()
	draw_origin()
func draw_origin():
	var origin_size = 10 / camera_2d.zoom.x  # scale with zoom to keep visible
	var origin_color = Color(1, 0, 0)        # bright red

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
		var thickness = 1.0 / zoom  # scale line thickness inversely with zoom
		if line_index % MAJOR_LINE_EVERY == 0:
			color = Color(1.0, 0.643, 0.212, 1.0)
			thickness *= 2
		if line_index == 0:
			color = Color(0.8, 0.285, 0.0, 1.0)
			thickness *=2
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
			color = Color(1.0, 0.643, 0.212, 1.0)
			thickness *= 2
		if line_index == 0:
			
			color = Color(0.8, 0.285, 0.0, 1.0)
			thickness *=2
		draw_line(Vector2(left, y), Vector2(right, y), color, thickness)
		y += GRID_SIZE
		line_index += 1
