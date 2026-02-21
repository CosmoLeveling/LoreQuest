extends Control
@onready var point: Panel = $Point
const ROOM_TEMPLATE = preload("uid://dsj0oxt3t4gyc")
@onready var background: Node2D = $Background
@onready var name_line: LineEdit = $CanvasLayer/LineName/NameSelect/MarginContainer/VBoxContainer/NameLine
@onready var line_name: CenterContainer = $CanvasLayer/LineName

@onready var room_box: VBoxContainer = $CanvasLayer/Panel/MarginContainer/VBoxContainer/ScrollContainer/RoomBox
@onready var camera_2d: Camera2D = $Camera2D

var wall_room:Room
var floor_room:Room
const TILE_SIZE: Vector2 = Vector2(10,10)
var world:World
var dragged_point_index: int = -1
var is_dragging := false
const POINT_RADIUS := 8.0
var current_room:Room
var ZOOM_STEP := 0.1   # how much to zoom per scroll
var MIN_ZOOM := 0.1
var MAX_ZOOM := 4.0
@onready var wall_dialog: FileDialog = $WallDialog
@onready var floor_dialog: FileDialog = $FloorDialog


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		point.global_position = _get_grid_point(get_global_mouse_position()) - TILE_SIZE/2.0
func _zoom_camera(_mouse_pos: Vector2, zoom_factor: float):
	var world_pos_before = camera_2d.get_global_mouse_position()
	
	# Apply zoom
	camera_2d.zoom *= zoom_factor
	
	# Clamp zoom
	camera_2d.zoom.x = clamp(camera_2d.zoom.x, MIN_ZOOM, MAX_ZOOM)
	camera_2d.zoom.y = clamp(camera_2d.zoom.y, MIN_ZOOM, MAX_ZOOM)
	
	# Adjust camera so the point under the mouse stays fixed
	var world_pos_after = camera_2d.get_global_mouse_position()
	camera_2d.position += world_pos_before - world_pos_after


	

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			_zoom_camera(event.position, 1.0 - ZOOM_STEP)
			background.queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			_zoom_camera(event.position, 1.0 + ZOOM_STEP)
			background.queue_redraw()
		if not current_room:
			return
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if _try_start_drag():
					return
				var pos:Vector2 = _get_grid_point(get_global_mouse_position())
				if current_room.can_add_point(pos):
					current_room.add_point(pos)
			else:
				_stop_drag()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				_try_remove_point()
				
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			camera_2d.position -= event.relative / camera_2d.zoom
			background.queue_redraw()
		if is_dragging:
			_update_drag()
func _try_remove_point():
	var mouse_pos = _get_grid_point(get_global_mouse_position())
	var index = current_room.get_point_at_position(mouse_pos, POINT_RADIUS)
	if index != -1:
		current_room.remove_point(index)
		return
func _stop_drag():
	is_dragging = false
	dragged_point_index = -1
func _try_start_drag():
	var mouse_pos = _get_grid_point(get_global_mouse_position())
	var index = current_room.get_point_at_position(mouse_pos, POINT_RADIUS)
	if index != -1:
		dragged_point_index = index
		is_dragging = true
		return true
	else:
		index = current_room.is_label_at_position(mouse_pos,
		POINT_RADIUS)
		if index != -1:
			current_room.label_auto = false
			dragged_point_index = index
			is_dragging = true
			return true
		return false
func _update_drag():
	if current_room == null:
		return

	var new_pos = _get_grid_point(get_global_mouse_position())
	
	if dragged_point_index == -2:
		current_room.label_pos = new_pos
		current_room.points_changed.emit()
		return
	
	if current_room.can_move_point(dragged_point_index, new_pos):
		current_room.points[dragged_point_index] = new_pos
		current_room.points_changed.emit()

func init() -> void:
	for c in room_box.get_children():
		c.queue_free()
	for r:Room in world.rooms:
		var temp:RoomTemplate = ROOM_TEMPLATE.instantiate()
		temp.room = r
		room_box.add_child(temp)
		temp.delete.connect(delete_room)
		temp.select.connect(select_room)
		temp.wall_change.connect(change_wall)
		temp.floor_change.connect(change_floor)
		var renderer:RoomRenderer = RoomRenderer.new()
		renderer.room = r
		add_child(renderer)

func change_wall(room:Room) -> void:
	wall_dialog.popup_file_dialog()
	wall_room = room
func change_floor(room:Room) -> void:
	floor_dialog.popup_file_dialog()
	floor_room = room
func delete_room(room:Room):
	room._destroy()
	world.rooms.erase(room)

func select_room(room:Room):
	if current_room:
		current_room.selected = false
		current_room.points_changed.emit()
	room.selected = true
	room.points_changed.emit()
	current_room = room

func _get_grid_point(pos:Vector2):
	var new_pos:Vector2= pos.snapped(TILE_SIZE)
	return new_pos


func _on_new_room_pressed() -> void:
	name_line.text = ""
	line_name.show()


func _on_submit_name_pressed() -> void:
	var new_room:Room = Room.new(name_line.text)
	world.rooms.append(new_room)
	var temp:RoomTemplate = ROOM_TEMPLATE.instantiate()
	temp.room = new_room
	room_box.add_child(temp)
	temp.select.connect(select_room)
	temp.delete.connect(delete_room)
	var renderer:RoomRenderer = RoomRenderer.new()
	renderer.room = new_room
	add_child(renderer)
	line_name.hide()

func _on_floor_dialog_file_selected(path: String) -> void:
	floor_room.floor_file_path = path
	floor_room.points_changed.emit()

func _on_wall_dialog_file_selected(path: String) -> void:
	wall_room.wall_file_path = path
	wall_room.points_changed.emit()
