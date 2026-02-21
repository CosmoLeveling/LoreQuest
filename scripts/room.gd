class_name Room
extends Resource
signal points_changed
var points:PackedVector2Array
var label_pos:Vector2 = Vector2.ZERO
var label_auto:bool = true
var name:String = ""
var wall_file_path:String=""
var floor_file_path:String=""
var selected = false
signal destroy()
func _init(new_name:String) -> void:
	self.name = new_name
func get_point_at_position(pos: Vector2, radius: float) -> int:
	for i in range(points.size()):
		if points[i].distance_to(pos) <= radius:
			return i
	return -1

func is_label_at_position(pos: Vector2, radius:float) -> int:
	if label_pos.distance_to(pos) <= radius:
		return -2
	return -1

func _destroy():
	destroy.emit()
func get_largest_triangle_centroid() -> Vector2:
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	if indices.is_empty():
		return points[0] if points.size() > 0 else Vector2.ZERO
	
	var max_area = -1.0
	var best_center = Vector2.ZERO
	
	for i in range(0, indices.size(), 3):
		var a = points[indices[i]]
		var b = points[indices[i + 1]]
		var c = points[indices[i + 2]]
		
		# Triangle area formula
		var area = abs((a.x*(b.y-c.y) + b.x*(c.y-a.y) + c.x*(a.y-b.y)) / 2.0)
		
		if area > max_area:
			max_area = area
			best_center = (a + b + c) / 3.0
	
	return best_center



func add_point(p: Vector2):
	points.append(p)
	points_changed.emit()
func can_move_point(index: int, new_pos: Vector2) -> bool:
	var temp_points = points.duplicate()
	temp_points[index] = new_pos

	# Check every pair of edges for intersection
	for i in range(temp_points.size()):
		var a1 = temp_points[i]
		var a2 = temp_points[(i + 1) % temp_points.size()]

		for j in range(i + 1, temp_points.size()):
			# Skip adjacent edges
			if abs(i - j) <= 1:
				continue
			if i == 0 and j == temp_points.size() - 1:
				continue

			var b1 = temp_points[j]
			var b2 = temp_points[(j + 1) % temp_points.size()]

			if Geometry2D.segment_intersects_segment(a1, a2, b1, b2) != null:
				return false

	return true
func remove_point(index: int):
	if can_remove_point(index):
		points.remove_at(index)
		points_changed.emit()
func can_remove_point(index: int) -> bool:
	if points.size() <= 3:
		return false

	var temp = points.duplicate()
	temp.remove_at(index)

	# Validate resulting polygon
	for i in range(temp.size()):
		var a1 = temp[i]
		var a2 = temp[(i + 1) % temp.size()]

		for j in range(i + 1, temp.size()):
			if abs(i - j) <= 1:
				continue
			if i == 0 and j == temp.size() - 1:
				continue

			var b1 = temp[j]
			var b2 = temp[(j + 1) % temp.size()]

			if Geometry2D.segment_intersects_segment(a1, a2, b1, b2) != null:
				return false

	return true

func can_add_point(new_point: Vector2) -> bool:
	var count := points.size()

	# If fewer than 2 points, nothing can intersect
	if count < 2:
		return true

	var last_point := points[count - 1]
	var first_point := points[0]

	# ----- Check NEW EDGE: last -> new -----
	for i in range(count - 1):
		var a := points[i]
		var b := points[i + 1]

		# Skip edge that shares the last_point
		if b == last_point:
			continue

		if Geometry2D.segment_intersects_segment(
			last_point, new_point,
			a, b
		) != null:
			return false

	# ----- Check CLOSING EDGE: new -> first -----
	# Only matters if we have at least 3 existing points
	if count >= 2:
		for i in range(count - 1):
			var a := points[i]
			var b := points[i + 1]

			# Skip edges that share first_point
			if a == first_point:
				continue

			if Geometry2D.segment_intersects_segment(
				new_point, first_point,
				a, b
			) != null:
				return false

	return true


func save():
	var data_dict:Dictionary
	data_dict["name"] = name
	var points_x:Array[float]
	var points_y:Array[float]
	for point in points:
		points_x.append(point.x/40)
		points_y.append(point.y/40)
	data_dict["points_x"] = points_x
	data_dict["points_y"] = points_y
	data_dict["label_auto"] = label_auto
	data_dict["label_pos_x"] = label_pos.x/40
	data_dict["label_pos_y"] = label_pos.y/40
	data_dict["floor_path"] = floor_file_path
	data_dict["wall_path"] = wall_file_path
	return data_dict

static func load_from_data(data:Dictionary):
	var new_room = Room.new(data.get("name",""))
	new_room.floor_file_path = data.get("floor_path","")
	new_room.wall_file_path = data.get("wall_path","")
	for vec in range(0,data.get("points_x",[]).size()):
		new_room.add_point(Vector2(
			data.get("points_x",[]).get(vec)*40,
			data.get("points_y",[]).get(vec)*40
		))
	new_room.label_auto = data.get("label_auto",true)
	new_room.label_pos.x = data.get("label_pos_x",0)*40
	new_room.label_pos.y = data.get("label_pos_y",0)*40
	# It is grid based .25 
	return new_room
