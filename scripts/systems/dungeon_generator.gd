class_name DungeonGenerator
extends Node

signal room_entered(room_data: RoomData)
signal room_generated(room_data: RoomData)

const ROOM_SCENE := preload("res://scenes/rooms/generated_room.tscn")

var room_generator := RoomGenerator.new()
var rooms: Dictionary = {}  # Vector2i -> RoomData
var room_instances: Dictionary = {}  # Vector2i -> Node2D
var current_room_pos: Vector2i = Vector2i.ZERO
var max_depth: int = 8

@onready var room_container: Node2D

func _ready() -> void:
	room_container = Node2D.new()
	room_container.name = "RoomContainer"
	add_child(room_container)

func generate_dungeon() -> void:
	rooms.clear()
	_clear_room_instances()

	# Generate starting room at origin
	var start_room := room_generator.generate_room(1)
	start_room.grid_position = Vector2i.ZERO
	rooms[Vector2i.ZERO] = start_room

	# Generate path to max depth
	var current_pos := Vector2i.ZERO
	for depth in range(2, max_depth + 1):
		var direction := _get_random_direction()
		var next_pos := current_pos + RoomData.direction_to_vector(direction)

		# Avoid overwriting existing rooms
		var attempts := 0
		while rooms.has(next_pos) and attempts < 10:
			direction = _get_random_direction()
			next_pos = current_pos + RoomData.direction_to_vector(direction)
			attempts += 1

		if rooms.has(next_pos):
			continue

		# Create new room with door connecting back
		var opposite := RoomData.opposite_direction(direction)
		var required_doors: Array[RoomData.DoorDirection] = [opposite]
		var new_room := room_generator.generate_room(depth, required_doors)
		new_room.grid_position = next_pos
		rooms[next_pos] = new_room

		# Ensure current room has door to new room
		if direction not in rooms[current_pos].doors:
			rooms[current_pos].doors.append(direction)

		room_generated.emit(new_room)
		current_pos = next_pos

	# Generate some side rooms
	_generate_side_rooms()

func _generate_side_rooms() -> void:
	var main_path := rooms.keys()
	for pos in main_path:
		if randf() < 0.3:  # 30% chance for side room
			var room_data: RoomData = rooms[pos]
			for dir in [RoomData.DoorDirection.NORTH, RoomData.DoorDirection.SOUTH,
						RoomData.DoorDirection.EAST, RoomData.DoorDirection.WEST]:
				var side_pos := pos + RoomData.direction_to_vector(dir)
				if not rooms.has(side_pos) and randf() < 0.5:
					var opposite := RoomData.opposite_direction(dir)
					var required: Array[RoomData.DoorDirection] = [opposite]
					var side_room := room_generator.generate_room(room_data.depth, required)
					side_room.grid_position = side_pos
					rooms[side_pos] = side_room

					if dir not in room_data.doors:
						room_data.doors.append(dir)
					break

func enter_room(grid_pos: Vector2i) -> void:
	if not rooms.has(grid_pos):
		return

	current_room_pos = grid_pos
	_update_visible_rooms()
	room_entered.emit(rooms[grid_pos])

func get_current_room() -> RoomData:
	return rooms.get(current_room_pos)

func get_room_instance(grid_pos: Vector2i) -> Node2D:
	if not room_instances.has(grid_pos):
		_instantiate_room(grid_pos)
	return room_instances.get(grid_pos)

func _instantiate_room(grid_pos: Vector2i) -> void:
	if not rooms.has(grid_pos):
		return
	if room_instances.has(grid_pos):
		return

	var room_data: RoomData = rooms[grid_pos]
	var room_instance: Node2D = ROOM_SCENE.instantiate()
	room_instance.setup(room_data, self)
	room_container.add_child(room_instance)
	room_instances[grid_pos] = room_instance

func _update_visible_rooms() -> void:
	# Load current room and adjacent rooms
	var to_load: Array[Vector2i] = [current_room_pos]
	for dir in [RoomData.DoorDirection.NORTH, RoomData.DoorDirection.SOUTH,
				RoomData.DoorDirection.EAST, RoomData.DoorDirection.WEST]:
		var adjacent := current_room_pos + RoomData.direction_to_vector(dir)
		if rooms.has(adjacent):
			to_load.append(adjacent)

	# Instantiate needed rooms
	for pos in to_load:
		if not room_instances.has(pos):
			_instantiate_room(pos)

	# Hide distant rooms (more than 1 step away)
	for pos in room_instances.keys():
		var instance: Node2D = room_instances[pos]
		var distance := abs(pos.x - current_room_pos.x) + abs(pos.y - current_room_pos.y)
		instance.visible = distance <= 1

func _clear_room_instances() -> void:
	for instance in room_instances.values():
		instance.queue_free()
	room_instances.clear()

func _get_random_direction() -> RoomData.DoorDirection:
	var dirs: Array[RoomData.DoorDirection] = [
		RoomData.DoorDirection.NORTH,
		RoomData.DoorDirection.SOUTH,
		RoomData.DoorDirection.EAST,
		RoomData.DoorDirection.WEST
	]
	return dirs[randi() % dirs.size()]

func get_adjacent_room_position(direction: RoomData.DoorDirection) -> Vector2i:
	return current_room_pos + RoomData.direction_to_vector(direction)

func has_adjacent_room(direction: RoomData.DoorDirection) -> bool:
	var adjacent := get_adjacent_room_position(direction)
	return rooms.has(adjacent)
