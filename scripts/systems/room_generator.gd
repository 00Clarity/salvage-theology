class_name RoomGenerator
extends RefCounted

const MIN_WIDTH := 10
const MAX_WIDTH := 18
const MIN_HEIGHT := 8
const MAX_HEIGHT := 14

func generate_room(depth: int, required_doors: Array[RoomData.DoorDirection] = []) -> RoomData:
	var room := RoomData.new()

	# Random size, larger rooms deeper in
	var size_bonus := mini(depth / 3, 4)
	room.width = randi_range(MIN_WIDTH, MAX_WIDTH + size_bonus)
	room.height = randi_range(MIN_HEIGHT, MAX_HEIGHT + size_bonus)
	room.depth = depth

	# Determine room type based on depth
	room.room_type = _get_room_type(depth)

	# Add required doors first
	for dir in required_doors:
		if dir not in room.doors:
			room.doors.append(dir)

	# Add additional random doors (2-4 total)
	var target_doors := randi_range(2, 4)
	var available_directions: Array[RoomData.DoorDirection] = [
		RoomData.DoorDirection.NORTH,
		RoomData.DoorDirection.SOUTH,
		RoomData.DoorDirection.EAST,
		RoomData.DoorDirection.WEST
	]

	while room.doors.size() < target_doors:
		var remaining := available_directions.filter(func(d): return d not in room.doors)
		if remaining.is_empty():
			break
		var dir: RoomData.DoorDirection = remaining[randi() % remaining.size()]
		room.doors.append(dir)

	return room

func _get_room_type(depth: int) -> RoomData.RoomType:
	var roll := randf()

	# Deeper = more special rooms
	if depth >= 5 and roll < 0.15:
		return RoomData.RoomType.SHRINE
	elif depth >= 3 and roll < 0.25:
		return RoomData.RoomType.HAZARD
	elif roll < 0.4:
		return RoomData.RoomType.CHAMBER
	else:
		return RoomData.RoomType.PASSAGE
