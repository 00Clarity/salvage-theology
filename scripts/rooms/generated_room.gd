extends Node2D

# Calyx color palette from FOUNDATION.md
const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")
const CALYX_DARK := Color("#0a2020")
const CALYX_FLOOR := Color("#061414")
const CALYX_WALL := Color("#0a2a2a")
const CALYX_ACCENT := Color("#00ffff", 0.6)
const CALYX_GLOW := Color("#00ffff", 0.3)

const TILE_SIZE := 32

var room_data: RoomData
var dungeon_generator: DungeonGenerator
var doors: Dictionary = {}  # DoorDirection -> TheologyDoor
var room_id: String = ""
var enemies: Array[Node2D] = []
var materials: Array[Node2D] = []
var extraction_point: Node2D = null

signal door_entered(direction: RoomData.DoorDirection)
signal door_payment_requested(door: TheologyDoor)
signal player_entered_threshold(door: TheologyDoor)
signal player_exited_threshold(door: TheologyDoor)

func setup(data: RoomData, generator: DungeonGenerator) -> void:
	room_data = data
	dungeon_generator = generator
	room_id = "room_%d_%d" % [room_data.grid_position.x, room_data.grid_position.y]
	_generate_room()

func _generate_room() -> void:
	_create_floor()
	_create_walls()
	_create_doors()
	_create_collision()
	_add_room_decorations()
	_add_ambient_light()
	_spawn_enemies()
	_spawn_materials()
	_spawn_extraction_point()

func _spawn_enemies() -> void:
	enemies = EnemySpawner.spawn_enemies_for_room(self, room_data)

func _spawn_materials() -> void:
	materials = MaterialSpawner.spawn_materials_for_room(self, room_data)

func _spawn_extraction_point() -> void:
	# Only spawn extraction point in starting room (depth 1, position 0,0)
	if room_data.depth == 1 and room_data.grid_position == Vector2i.ZERO:
		var ExtractionPointScene := preload("res://scenes/systems/extraction_point.tscn")
		extraction_point = ExtractionPointScene.instantiate()
		extraction_point.position = Vector2(0, 0)  # Center of room
		add_child(extraction_point)

func _create_floor() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0
	var inset := TILE_SIZE

	# Main floor
	var floor_poly := Polygon2D.new()
	floor_poly.polygon = PackedVector2Array([
		Vector2(-half_w + inset, -half_h + inset),
		Vector2(half_w - inset, -half_h + inset),
		Vector2(half_w - inset, half_h - inset),
		Vector2(-half_w + inset, half_h - inset)
	])
	floor_poly.color = CALYX_FLOOR
	floor_poly.z_index = -10
	add_child(floor_poly)

	# Floor grid pattern
	_create_floor_grid(half_w, half_h, inset)

func _create_floor_grid(half_w: float, half_h: float, inset: float) -> void:
	var grid_container := Node2D.new()
	grid_container.z_index = -9

	# Vertical lines
	var x := -half_w + inset + TILE_SIZE
	while x < half_w - inset:
		var line := Line2D.new()
		line.points = PackedVector2Array([
			Vector2(x, -half_h + inset),
			Vector2(x, half_h - inset)
		])
		line.width = 1.0
		line.default_color = Color(CALYX_TEAL, 0.08)
		grid_container.add_child(line)
		x += TILE_SIZE * 2

	# Horizontal lines
	var y := -half_h + inset + TILE_SIZE
	while y < half_h - inset:
		var line := Line2D.new()
		line.points = PackedVector2Array([
			Vector2(-half_w + inset, y),
			Vector2(half_w - inset, y)
		])
		line.width = 1.0
		line.default_color = Color(CALYX_TEAL, 0.08)
		grid_container.add_child(line)
		y += TILE_SIZE * 2

	add_child(grid_container)

func _create_walls() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	# North wall
	_create_wall_section(
		Vector2(-half_w, -half_h),
		Vector2(half_w, -half_h + TILE_SIZE),
		RoomData.DoorDirection.NORTH,
		true
	)
	# South wall
	_create_wall_section(
		Vector2(-half_w, half_h - TILE_SIZE),
		Vector2(half_w, half_h),
		RoomData.DoorDirection.SOUTH,
		true
	)
	# West wall
	_create_wall_section(
		Vector2(-half_w, -half_h),
		Vector2(-half_w + TILE_SIZE, half_h),
		RoomData.DoorDirection.WEST,
		false
	)
	# East wall
	_create_wall_section(
		Vector2(half_w - TILE_SIZE, -half_h),
		Vector2(half_w, half_h),
		RoomData.DoorDirection.EAST,
		false
	)

	# Corner accents
	_create_corner_accents(half_w, half_h)

func _create_wall_section(from: Vector2, to: Vector2, direction: RoomData.DoorDirection, is_horizontal: bool) -> void:
	var has_door = direction in room_data.doors
	var door_half_size := TILE_SIZE * 1.5

	if has_door:
		if is_horizontal:
			var mid_x := (from.x + to.x) / 2.0
			# Left segment
			_create_wall_polygon(from, Vector2(mid_x - door_half_size, to.y))
			# Right segment
			_create_wall_polygon(Vector2(mid_x + door_half_size, from.y), to)
		else:
			var mid_y := (from.y + to.y) / 2.0
			# Top segment
			_create_wall_polygon(from, Vector2(to.x, mid_y - door_half_size))
			# Bottom segment
			_create_wall_polygon(Vector2(from.x, mid_y + door_half_size), to)
	else:
		_create_wall_polygon(from, to)

func _create_wall_polygon(from: Vector2, to: Vector2) -> void:
	var wall := Polygon2D.new()
	wall.polygon = PackedVector2Array([
		from,
		Vector2(to.x, from.y),
		to,
		Vector2(from.x, to.y)
	])
	wall.color = CALYX_WALL
	wall.z_index = -5
	add_child(wall)

	# Inner edge glow line
	var is_horizontal := abs(to.y - from.y) < abs(to.x - from.x)
	var accent := Line2D.new()

	if is_horizontal:
		var y_inner := to.y if from.y < 0 else from.y
		accent.points = PackedVector2Array([
			Vector2(from.x, y_inner),
			Vector2(to.x, y_inner)
		])
	else:
		var x_inner := to.x if from.x < 0 else from.x
		accent.points = PackedVector2Array([
			Vector2(x_inner, from.y),
			Vector2(x_inner, to.y)
		])

	accent.width = 2.0
	accent.default_color = CALYX_ACCENT
	accent.z_index = -4
	add_child(accent)

func _create_corner_accents(half_w: float, half_h: float) -> void:
	var corners := [
		[Vector2(-half_w + TILE_SIZE, -half_h + TILE_SIZE), 0],  # Top-left
		[Vector2(half_w - TILE_SIZE, -half_h + TILE_SIZE), 1],   # Top-right
		[Vector2(half_w - TILE_SIZE, half_h - TILE_SIZE), 2],    # Bottom-right
		[Vector2(-half_w + TILE_SIZE, half_h - TILE_SIZE), 3]    # Bottom-left
	]

	for corner_data in corners:
		var pos: Vector2 = corner_data[0]
		var corner_idx: int = corner_data[1]
		_create_corner_accent(pos, corner_idx)

func _create_corner_accent(pos: Vector2, corner: int) -> void:
	var accent := Polygon2D.new()
	var size := 12.0

	match corner:
		0:  # Top-left - L shape pointing into room
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(size, 0), pos + Vector2(size, 3),
				pos + Vector2(3, 3), pos + Vector2(3, size), pos + Vector2(0, size)
			])
		1:  # Top-right
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(0, size), pos + Vector2(-3, size),
				pos + Vector2(-3, 3), pos + Vector2(-size, 3), pos + Vector2(-size, 0)
			])
		2:  # Bottom-right
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(-size, 0), pos + Vector2(-size, -3),
				pos + Vector2(-3, -3), pos + Vector2(-3, -size), pos + Vector2(0, -size)
			])
		3:  # Bottom-left
			accent.polygon = PackedVector2Array([
				pos, pos + Vector2(0, -size), pos + Vector2(3, -size),
				pos + Vector2(3, -3), pos + Vector2(size, -3), pos + Vector2(size, 0)
			])

	accent.color = CALYX_GLOW
	accent.z_index = -3
	add_child(accent)

func _create_doors() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	for direction in room_data.doors:
		var door_pos: Vector2
		var door_size: Vector2
		var is_vertical: bool

		match direction:
			RoomData.DoorDirection.NORTH:
				door_pos = Vector2(0, -half_h + TILE_SIZE / 2.0)
				door_size = Vector2(TILE_SIZE * 3, TILE_SIZE * 1.5)
				is_vertical = false
			RoomData.DoorDirection.SOUTH:
				door_pos = Vector2(0, half_h - TILE_SIZE / 2.0)
				door_size = Vector2(TILE_SIZE * 3, TILE_SIZE * 1.5)
				is_vertical = false
			RoomData.DoorDirection.EAST:
				door_pos = Vector2(half_w - TILE_SIZE / 2.0, 0)
				door_size = Vector2(TILE_SIZE * 1.5, TILE_SIZE * 3)
				is_vertical = true
			RoomData.DoorDirection.WEST:
				door_pos = Vector2(-half_w + TILE_SIZE / 2.0, 0)
				door_size = Vector2(TILE_SIZE * 1.5, TILE_SIZE * 3)
				is_vertical = true

		_create_door(direction, door_pos, door_size, is_vertical)

func _create_door(direction: RoomData.DoorDirection, pos: Vector2, size: Vector2, _is_vertical: bool) -> void:
	# Create TheologyDoor with payment system
	var door := TheologyDoor.new()
	door.room_id = room_id
	door.setup(direction, pos, size)

	# Check if door was previously opened (permanence rule)
	if GameManager.is_door_open(room_id, door.door_id):
		door.state = TheologyDoor.DoorState.OPEN

	# Connect signals
	door.door_opened.connect(_on_theology_door_opened.bind(direction))
	door.payment_requested.connect(_on_door_payment_requested)
	door.player_entered_threshold.connect(_on_player_entered_threshold)
	door.player_exited_threshold.connect(_on_player_exited_threshold)

	add_child(door)
	doors[direction] = door

func _on_theology_door_opened(_door: TheologyDoor, direction: RoomData.DoorDirection) -> void:
	door_entered.emit(direction)

func _on_door_payment_requested(door: TheologyDoor) -> void:
	door_payment_requested.emit(door)

func _on_player_entered_threshold(door: TheologyDoor) -> void:
	player_entered_threshold.emit(door)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("enter_threshold"):
		player.enter_threshold()

func _on_player_exited_threshold(door: TheologyDoor) -> void:
	player_exited_threshold.emit(door)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("exit_threshold"):
		player.exit_threshold()

func _create_collision() -> void:
	var half_w := room_data.width * TILE_SIZE / 2.0
	var half_h := room_data.height * TILE_SIZE / 2.0

	for direction in [RoomData.DoorDirection.NORTH, RoomData.DoorDirection.SOUTH,
					  RoomData.DoorDirection.EAST, RoomData.DoorDirection.WEST]:
		_create_wall_collision(direction, half_w, half_h)

func _create_wall_collision(direction: RoomData.DoorDirection, half_w: float, half_h: float) -> void:
	var has_door = direction in room_data.doors
	var door_half_size := TILE_SIZE * 1.5

	match direction:
		RoomData.DoorDirection.NORTH:
			if has_door:
				# Left and right wall segments around door
				_add_collision_rect(
					Vector2(-half_w / 2.0 - door_half_size / 2.0, -half_h + TILE_SIZE / 2.0),
					Vector2(half_w - door_half_size * 2, TILE_SIZE)
				)
				_add_collision_rect(
					Vector2(half_w / 2.0 + door_half_size / 2.0, -half_h + TILE_SIZE / 2.0),
					Vector2(half_w - door_half_size * 2, TILE_SIZE)
				)
			else:
				_add_collision_rect(
					Vector2(0, -half_h + TILE_SIZE / 2.0),
					Vector2(half_w * 2, TILE_SIZE)
				)

		RoomData.DoorDirection.SOUTH:
			if has_door:
				_add_collision_rect(
					Vector2(-half_w / 2.0 - door_half_size / 2.0, half_h - TILE_SIZE / 2.0),
					Vector2(half_w - door_half_size * 2, TILE_SIZE)
				)
				_add_collision_rect(
					Vector2(half_w / 2.0 + door_half_size / 2.0, half_h - TILE_SIZE / 2.0),
					Vector2(half_w - door_half_size * 2, TILE_SIZE)
				)
			else:
				_add_collision_rect(
					Vector2(0, half_h - TILE_SIZE / 2.0),
					Vector2(half_w * 2, TILE_SIZE)
				)

		RoomData.DoorDirection.WEST:
			if has_door:
				_add_collision_rect(
					Vector2(-half_w + TILE_SIZE / 2.0, -half_h / 2.0 - door_half_size / 2.0),
					Vector2(TILE_SIZE, half_h - door_half_size * 2)
				)
				_add_collision_rect(
					Vector2(-half_w + TILE_SIZE / 2.0, half_h / 2.0 + door_half_size / 2.0),
					Vector2(TILE_SIZE, half_h - door_half_size * 2)
				)
			else:
				_add_collision_rect(
					Vector2(-half_w + TILE_SIZE / 2.0, 0),
					Vector2(TILE_SIZE, half_h * 2)
				)

		RoomData.DoorDirection.EAST:
			if has_door:
				_add_collision_rect(
					Vector2(half_w - TILE_SIZE / 2.0, -half_h / 2.0 - door_half_size / 2.0),
					Vector2(TILE_SIZE, half_h - door_half_size * 2)
				)
				_add_collision_rect(
					Vector2(half_w - TILE_SIZE / 2.0, half_h / 2.0 + door_half_size / 2.0),
					Vector2(TILE_SIZE, half_h - door_half_size * 2)
				)
			else:
				_add_collision_rect(
					Vector2(half_w - TILE_SIZE / 2.0, 0),
					Vector2(TILE_SIZE, half_h * 2)
				)

func _add_collision_rect(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)

func _add_room_decorations() -> void:
	match room_data.room_type:
		RoomData.RoomType.REST:
			_add_rest_decoration()
		RoomData.RoomType.VAULT:
			_add_vault_decoration()
		RoomData.RoomType.SANCTUM:
			_add_sanctum_decoration()
		RoomData.RoomType.HAZARD:
			_add_hazard_decoration()
		RoomData.RoomType.CHAMBER:
			_add_chamber_decoration()
		RoomData.RoomType.PASSAGE:
			_add_passage_decoration()

func _add_rest_decoration() -> void:
	# Oxygen cache - safe zone visual
	var cache := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(8):
		var angle := i * TAU / 8.0 - PI / 2.0
		points.append(Vector2(cos(angle), sin(angle)) * 28)
	cache.polygon = points
	cache.color = Color(CALYX_TEAL, 0.25)
	add_child(cache)

	# Inner octagon
	var inner := Polygon2D.new()
	var inner_points := PackedVector2Array()
	for i in range(8):
		var angle := i * TAU / 8.0 - PI / 2.0
		inner_points.append(Vector2(cos(angle), sin(angle)) * 16)
	inner.polygon = inner_points
	inner.color = Color(CALYX_CYAN, 0.15)
	add_child(inner)

	# Soft glow
	var light := PointLight2D.new()
	light.color = CALYX_TEAL
	light.energy = 0.6
	_setup_point_light(light, 1.2)
	add_child(light)

func _add_vault_decoration() -> void:
	# Treasure marker - diamond shape
	var vault := Polygon2D.new()
	vault.polygon = PackedVector2Array([
		Vector2(0, -24),
		Vector2(24, 0),
		Vector2(0, 24),
		Vector2(-24, 0)
	])
	vault.color = Color("#ffd700", 0.3)  # Gold tint
	add_child(vault)

	# Inner diamond
	var inner := Polygon2D.new()
	inner.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(12, 0),
		Vector2(0, 12),
		Vector2(-12, 0)
	])
	inner.color = Color("#ffd700", 0.5)
	add_child(inner)

	# Golden glow
	var light := PointLight2D.new()
	light.color = Color("#ffd700")
	light.energy = 0.5
	_setup_point_light(light, 0.8)
	add_child(light)

func _add_sanctum_decoration() -> void:
	# Theology puzzle room - hexagonal altar
	var altar := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0 - PI / 2.0
		points.append(Vector2(cos(angle), sin(angle)) * 32)
	altar.polygon = points
	altar.color = Color(CALYX_CYAN, 0.2)
	add_child(altar)

	# Glowing runes (three small triangles)
	for i in range(3):
		var rune := Polygon2D.new()
		var angle := i * TAU / 3.0 - PI / 2.0
		var offset := Vector2(cos(angle), sin(angle)) * 20
		rune.polygon = PackedVector2Array([
			offset + Vector2(0, -6),
			offset + Vector2(5, 3),
			offset + Vector2(-5, 3)
		])
		rune.color = CALYX_CYAN
		add_child(rune)

	# Sacred glow
	var light := PointLight2D.new()
	light.color = CALYX_CYAN
	light.energy = 0.7
	_setup_point_light(light, 1.0)
	add_child(light)

func _add_hazard_decoration() -> void:
	# Warning triangle
	var warning := Polygon2D.new()
	warning.polygon = PackedVector2Array([
		Vector2(0, -24),
		Vector2(21, 12),
		Vector2(-21, 12)
	])
	warning.color = Color("#ff6600", 0.4)  # Orange warning
	add_child(warning)

	# Inner triangle (inverted)
	var inner := Polygon2D.new()
	inner.polygon = PackedVector2Array([
		Vector2(0, -8),
		Vector2(7, 4),
		Vector2(-7, 4)
	])
	inner.color = Color("#ff3300", 0.6)  # Red danger
	add_child(inner)

	# Warning glow
	var light := PointLight2D.new()
	light.color = Color("#ff4400")
	light.energy = 0.5
	_setup_point_light(light, 0.6)
	add_child(light)

func _add_chamber_decoration() -> void:
	# Combat room - scattered floor markings
	for i in range(randi_range(3, 5)):
		var mark := Line2D.new()
		var pos := Vector2(
			randf_range(-room_data.width * TILE_SIZE / 4.0, room_data.width * TILE_SIZE / 4.0),
			randf_range(-room_data.height * TILE_SIZE / 4.0, room_data.height * TILE_SIZE / 4.0)
		)
		var end_pos := pos + Vector2(randf_range(-24, 24), randf_range(-24, 24))
		mark.points = PackedVector2Array([pos, end_pos])
		mark.width = 2.0
		mark.default_color = Color(CALYX_TEAL, 0.15)
		mark.z_index = -7
		add_child(mark)

func _add_passage_decoration() -> void:
	# Simple connector - minimal decoration
	# Just add subtle corner markers
	var markers_pos := [
		Vector2(-room_data.width * TILE_SIZE / 4.0, -room_data.height * TILE_SIZE / 4.0),
		Vector2(room_data.width * TILE_SIZE / 4.0, room_data.height * TILE_SIZE / 4.0)
	]

	for pos in markers_pos:
		var marker := Polygon2D.new()
		marker.polygon = PackedVector2Array([
			pos + Vector2(-4, 0),
			pos + Vector2(0, -4),
			pos + Vector2(4, 0),
			pos + Vector2(0, 4)
		])
		marker.color = Color(CALYX_TEAL, 0.1)
		marker.z_index = -7
		add_child(marker)

func _add_ambient_light() -> void:
	# Soft ambient light for the room
	var ambient := PointLight2D.new()
	ambient.color = CALYX_TEAL
	ambient.energy = 0.3
	_setup_point_light(ambient, 2.5)
	add_child(ambient)

func _setup_point_light(light: PointLight2D, scale: float) -> void:
	light.texture_scale = scale
	var gradient := GradientTexture2D.new()
	gradient.width = 128
	gradient.height = 128
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color.TRANSPARENT])
	gradient.gradient = grad
	light.texture = gradient
