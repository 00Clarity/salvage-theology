extends Node2D

const TILE_SIZE := 32
const WALL_COLOR := Color(0.039, 0.165, 0.165)
const FLOOR_COLOR := Color(0.039, 0.102, 0.102)
const ACCENT_COLOR := Color(0, 1, 1, 0.5)
const DOOR_COLOR := Color(0, 1, 1, 0.8)

var room_data: RoomData
var dungeon_generator: DungeonGenerator
var doors: Dictionary = {}  # DoorDirection -> Area2D

signal door_entered(direction: RoomData.DoorDirection)

func setup(data: RoomData, generator: DungeonGenerator) -> void:
	room_data = data
	dungeon_generator = generator
	_generate_visuals()
	_create_collision()
	_create_doors()

func _generate_visuals() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	# Floor
	var floor_poly := Polygon2D.new()
	floor_poly.polygon = PackedVector2Array([
		Vector2(-half_w + TILE_SIZE, -half_h + TILE_SIZE),
		Vector2(half_w - TILE_SIZE, -half_h + TILE_SIZE),
		Vector2(half_w - TILE_SIZE, half_h - TILE_SIZE),
		Vector2(-half_w + TILE_SIZE, half_h - TILE_SIZE)
	])
	floor_poly.color = FLOOR_COLOR
	add_child(floor_poly)

	# Walls
	_create_wall(Vector2(-half_w, -half_h), Vector2(half_w, -half_h + TILE_SIZE), RoomData.DoorDirection.NORTH)
	_create_wall(Vector2(-half_w, half_h - TILE_SIZE), Vector2(half_w, half_h), RoomData.DoorDirection.SOUTH)
	_create_wall(Vector2(-half_w, -half_h), Vector2(-half_w + TILE_SIZE, half_h), RoomData.DoorDirection.WEST)
	_create_wall(Vector2(half_w - TILE_SIZE, -half_h), Vector2(half_w, half_h), RoomData.DoorDirection.EAST)

	# Corner accents
	_create_corner_accent(Vector2(-half_w + TILE_SIZE, -half_h + TILE_SIZE), 0)
	_create_corner_accent(Vector2(half_w - TILE_SIZE, -half_h + TILE_SIZE), 1)
	_create_corner_accent(Vector2(half_w - TILE_SIZE, half_h - TILE_SIZE), 2)
	_create_corner_accent(Vector2(-half_w + TILE_SIZE, half_h - TILE_SIZE), 3)

	# Room type decorations
	_add_room_decorations()

func _create_wall(from: Vector2, to: Vector2, direction: RoomData.DoorDirection) -> void:
	var has_door = direction in room_data.doors

	if has_door:
		# Create wall with gap for door
		var door_size = TILE_SIZE * 2
		var is_horizontal = direction in [RoomData.DoorDirection.NORTH, RoomData.DoorDirection.SOUTH]

		if is_horizontal:
			var mid = (from.x + to.x) / 2.0
			# Left segment
			_create_wall_segment(from, Vector2(mid - door_size, to.y))
			# Right segment
			_create_wall_segment(Vector2(mid + door_size, from.y), to)
		else:
			var mid = (from.y + to.y) / 2.0
			# Top segment
			_create_wall_segment(from, Vector2(to.x, mid - door_size))
			# Bottom segment
			_create_wall_segment(Vector2(from.x, mid + door_size), to)
	else:
		_create_wall_segment(from, to)

func _create_wall_segment(from: Vector2, to: Vector2) -> void:
	var wall := Polygon2D.new()
	wall.polygon = PackedVector2Array([
		from,
		Vector2(to.x, from.y),
		to,
		Vector2(from.x, to.y)
	])
	wall.color = WALL_COLOR
	add_child(wall)

	# Accent line on inner edge
	var accent := Line2D.new()
	var is_horizontal = abs(to.y - from.y) < abs(to.x - from.x)
	if is_horizontal:
		var y_inner = to.y if from.y < 0 else from.y
		accent.points = PackedVector2Array([Vector2(from.x, y_inner), Vector2(to.x, y_inner)])
	else:
		var x_inner = to.x if from.x < 0 else from.x
		accent.points = PackedVector2Array([Vector2(x_inner, from.y), Vector2(x_inner, to.y)])
	accent.width = 2.0
	accent.default_color = ACCENT_COLOR
	add_child(accent)

func _create_corner_accent(pos: Vector2, corner: int) -> void:
	var accent := Polygon2D.new()
	var size := 16.0
	match corner:
		0:  # Top-left
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(size, 0), pos + Vector2(size, 4),
				pos + Vector2(4, 4), pos + Vector2(4, size), pos + Vector2(0, size)
			])
		1:  # Top-right
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(0, size), pos + Vector2(-4, size),
				pos + Vector2(-4, 4), pos + Vector2(-size, 4), pos + Vector2(-size, 0)
			])
		2:  # Bottom-right
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(-size, 0), pos + Vector2(-size, -4),
				pos + Vector2(-4, -4), pos + Vector2(-4, -size), pos + Vector2(0, -size)
			])
		3:  # Bottom-left
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(0, -size), pos + Vector2(4, -size),
				pos + Vector2(4, -4), pos + Vector2(size, -4), pos + Vector2(size, 0)
			])
	accent.color = Color(ACCENT_COLOR, 0.3)
	add_child(accent)

func _create_collision() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	# Create collision for each wall segment
	for direction in [RoomData.DoorDirection.NORTH, RoomData.DoorDirection.SOUTH,
					  RoomData.DoorDirection.EAST, RoomData.DoorDirection.WEST]:
		_create_wall_collision(direction, half_w, half_h)

func _create_wall_collision(direction: RoomData.DoorDirection, half_w: float, half_h: float) -> void:
	var has_door = direction in room_data.doors
	var door_size = TILE_SIZE * 2.0

	match direction:
		RoomData.DoorDirection.NORTH:
			if has_door:
				_add_static_body(Vector2(-half_w / 2.0 - door_size / 2.0, -half_h + TILE_SIZE / 2.0),
								 Vector2(half_w - door_size * 2, TILE_SIZE))
				_add_static_body(Vector2(half_w / 2.0 + door_size / 2.0, -half_h + TILE_SIZE / 2.0),
								 Vector2(half_w - door_size * 2, TILE_SIZE))
			else:
				_add_static_body(Vector2(0, -half_h + TILE_SIZE / 2.0), Vector2(half_w * 2, TILE_SIZE))

		RoomData.DoorDirection.SOUTH:
			if has_door:
				_add_static_body(Vector2(-half_w / 2.0 - door_size / 2.0, half_h - TILE_SIZE / 2.0),
								 Vector2(half_w - door_size * 2, TILE_SIZE))
				_add_static_body(Vector2(half_w / 2.0 + door_size / 2.0, half_h - TILE_SIZE / 2.0),
								 Vector2(half_w - door_size * 2, TILE_SIZE))
			else:
				_add_static_body(Vector2(0, half_h - TILE_SIZE / 2.0), Vector2(half_w * 2, TILE_SIZE))

		RoomData.DoorDirection.WEST:
			if has_door:
				_add_static_body(Vector2(-half_w + TILE_SIZE / 2.0, -half_h / 2.0 - door_size / 2.0),
								 Vector2(TILE_SIZE, half_h - door_size * 2))
				_add_static_body(Vector2(-half_w + TILE_SIZE / 2.0, half_h / 2.0 + door_size / 2.0),
								 Vector2(TILE_SIZE, half_h - door_size * 2))
			else:
				_add_static_body(Vector2(-half_w + TILE_SIZE / 2.0, 0), Vector2(TILE_SIZE, half_h * 2))

		RoomData.DoorDirection.EAST:
			if has_door:
				_add_static_body(Vector2(half_w - TILE_SIZE / 2.0, -half_h / 2.0 - door_size / 2.0),
								 Vector2(TILE_SIZE, half_h - door_size * 2))
				_add_static_body(Vector2(half_w - TILE_SIZE / 2.0, half_h / 2.0 + door_size / 2.0),
								 Vector2(TILE_SIZE, half_h - door_size * 2))
			else:
				_add_static_body(Vector2(half_w - TILE_SIZE / 2.0, 0), Vector2(TILE_SIZE, half_h * 2))

func _add_static_body(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)

func _create_doors() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	for direction in room_data.doors:
		var door_pos: Vector2
		var door_size: Vector2

		match direction:
			RoomData.DoorDirection.NORTH:
				door_pos = Vector2(0, -half_h + TILE_SIZE / 2.0)
				door_size = Vector2(TILE_SIZE * 3, TILE_SIZE * 1.5)
			RoomData.DoorDirection.SOUTH:
				door_pos = Vector2(0, half_h - TILE_SIZE / 2.0)
				door_size = Vector2(TILE_SIZE * 3, TILE_SIZE * 1.5)
			RoomData.DoorDirection.EAST:
				door_pos = Vector2(half_w - TILE_SIZE / 2.0, 0)
				door_size = Vector2(TILE_SIZE * 1.5, TILE_SIZE * 3)
			RoomData.DoorDirection.WEST:
				door_pos = Vector2(-half_w + TILE_SIZE / 2.0, 0)
				door_size = Vector2(TILE_SIZE * 1.5, TILE_SIZE * 3)

		_create_door_area(direction, door_pos, door_size)

func _create_door_area(direction: RoomData.DoorDirection, pos: Vector2, size: Vector2) -> void:
	var area := Area2D.new()
	area.position = pos
	area.set_meta("direction", direction)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	area.add_child(shape)

	# Visual indicator
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-size.x / 2, -size.y / 2),
		Vector2(size.x / 2, -size.y / 2),
		Vector2(size.x / 2, size.y / 2),
		Vector2(-size.x / 2, size.y / 2)
	])
	visual.color = Color(DOOR_COLOR, 0.3)
	area.add_child(visual)

	# Door frame accent
	var frame := Line2D.new()
	frame.points = PackedVector2Array([
		Vector2(-size.x / 2, -size.y / 2),
		Vector2(size.x / 2, -size.y / 2),
		Vector2(size.x / 2, size.y / 2),
		Vector2(-size.x / 2, size.y / 2),
		Vector2(-size.x / 2, -size.y / 2)
	])
	frame.width = 2.0
	frame.default_color = DOOR_COLOR
	area.add_child(frame)

	area.body_entered.connect(_on_door_body_entered.bind(direction))
	add_child(area)
	doors[direction] = area

func _on_door_body_entered(body: Node2D, direction: RoomData.DoorDirection) -> void:
	if body.is_in_group("player"):
		door_entered.emit(direction)

func _add_room_decorations() -> void:
	match room_data.room_type:
		RoomData.RoomType.SHRINE:
			_add_shrine_decoration()
		RoomData.RoomType.CHAMBER:
			_add_chamber_decoration()
		RoomData.RoomType.HAZARD:
			_add_hazard_decoration()

func _add_shrine_decoration() -> void:
	# Central altar marker
	var altar := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0 - PI / 2.0
		points.append(Vector2(cos(angle), sin(angle)) * 24)
	altar.polygon = points
	altar.color = Color(ACCENT_COLOR, 0.4)
	add_child(altar)

	var light := PointLight2D.new()
	light.color = ACCENT_COLOR
	light.energy = 0.5
	light.texture = load("res://assets/light_gradient.tres")
	light.texture_scale = 0.8
	add_child(light)

func _add_chamber_decoration() -> void:
	# Scattered floor markings
	for i in range(randi_range(2, 4)):
		var mark := Line2D.new()
		var pos := Vector2(
			randf_range(-room_data.width * TILE_SIZE / 4.0, room_data.width * TILE_SIZE / 4.0),
			randf_range(-room_data.height * TILE_SIZE / 4.0, room_data.height * TILE_SIZE / 4.0)
		)
		mark.points = PackedVector2Array([pos, pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))])
		mark.width = 1.0
		mark.default_color = Color(ACCENT_COLOR, 0.2)
		add_child(mark)

func _add_hazard_decoration() -> void:
	# Warning markers
	var center_marker := Polygon2D.new()
	center_marker.polygon = PackedVector2Array([
		Vector2(0, -20), Vector2(17, 10), Vector2(-17, 10)
	])
	center_marker.color = Color(1, 0.5, 0, 0.3)
	add_child(center_marker)
