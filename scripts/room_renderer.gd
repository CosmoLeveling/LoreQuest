class_name RoomRenderer
extends Node2D

var room: Room
const STAR = preload("uid://bxbq7pqchtm1s")
var polygon:Polygon2D
var line:Line2D
func _ready():
	var floor_image:Image = Image.new()
	if FileAccess.file_exists(room.floor_file_path):
		floor_image.load(room.floor_file_path)
	else:
		floor_image = load("res://assets/tile_default.png")
	var floor_image_texture = ImageTexture.new()
	floor_image_texture.set_image(floor_image)
	var wall_image:Image = Image.new()
	if FileAccess.file_exists(room.wall_file_path):
		wall_image.load(room.wall_file_path)
	else:
		wall_image = load("res://assets/wall_default.png")
	var wall_image_texture = ImageTexture.new()
	wall_image_texture.set_image(wall_image)
	polygon = Polygon2D.new()
	polygon.set_polygon(room.points)
	polygon.show_behind_parent = true
	polygon.uv = room.points
	polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	polygon.texture = floor_image_texture
	add_child(polygon)
	line = Line2D.new()
	line.closed = true
	line.width = 5
	line.points = room.points
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture = wall_image_texture
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	polygon.add_child(line)
	room.points_changed.connect(_on_room_changed)
	room.destroy.connect(destroy)

func destroy():
	queue_free()

func _on_room_changed():
	var floor_image:Image = Image.new()
	if FileAccess.file_exists(room.floor_file_path):
		floor_image.load(room.floor_file_path)
	else:
		floor_image = load("res://assets/tile_default.png")
	var floor_image_texture = ImageTexture.new()
	floor_image_texture.set_image(floor_image)
	var wall_image:Image = Image.new()
	if FileAccess.file_exists(room.wall_file_path):
		wall_image.load(room.wall_file_path)
	else:
		wall_image = load("res://assets/wall_default.png")
	var wall_image_texture = ImageTexture.new()
	wall_image_texture.set_image(wall_image)
	if room.selected:
		move_to_front()
	line.points = room.points
	line.texture = wall_image_texture
	polygon.set_polygon(room.points)
	polygon.texture = floor_image_texture
	polygon.uv = room.points
	queue_redraw()

func _draw():
	if room.points.size() >= 3:
		if room.name != "":
			if room.label_auto:
				room.label_pos = room.get_largest_triangle_centroid() 
			draw_circle(room.label_pos,
			5,
			Color.DARK_BLUE
			)
			draw_string(
				ThemeDB.fallback_font,
				room.label_pos,
				room.name,
				HORIZONTAL_ALIGNMENT_CENTER
			)
	if room.selected:
		for p in room.points:
			if room.points.find(p)==room.points.size()-1||room.points.find(p)==0:
				draw_texture(STAR,p-Vector2(STAR.get_height()*.5,STAR.get_height()*.5))
			else:
				draw_texture(STAR,p-Vector2(STAR.get_height()*.5,STAR.get_height()*.5),Color(0.5,0.5,1,1))
