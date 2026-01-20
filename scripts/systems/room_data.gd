class_name RoomData
extends Resource

enum RoomType { PASSAGE, CHAMBER, SHRINE, HAZARD }
enum DoorDirection { NORTH, SOUTH, EAST, WEST }

@export var width: int = 15
@export var height: int = 12
@export var room_type: RoomType = RoomType.PASSAGE
@export var doors: Array[DoorDirection] = []
@export var depth: int = 1

# Grid position in dungeon
var grid_position: Vector2i = Vector2i.ZERO

# Pixel size for rendering
const TILE_SIZE: int = 32

func get_pixel_size() -> Vector2:
	return Vector2(width * TILE_SIZE, height * TILE_SIZE)

func get_door_position(direction: DoorDirection) -> Vector2:
	var half_w := width * TILE_SIZE / 2.0
	var half_h := height * TILE_SIZE / 2.0

	match direction:
		DoorDirection.NORTH:
			return Vector2(0, -half_h)
		DoorDirection.SOUTH:
			return Vector2(0, half_h)
		DoorDirection.EAST:
			return Vector2(half_w, 0)
		DoorDirection.WEST:
			return Vector2(-half_w, 0)

	return Vector2.ZERO

static func opposite_direction(dir: DoorDirection) -> DoorDirection:
	match dir:
		DoorDirection.NORTH:
			return DoorDirection.SOUTH
		DoorDirection.SOUTH:
			return DoorDirection.NORTH
		DoorDirection.EAST:
			return DoorDirection.WEST
		DoorDirection.WEST:
			return DoorDirection.EAST
	return DoorDirection.NORTH

static func direction_to_vector(dir: DoorDirection) -> Vector2i:
	match dir:
		DoorDirection.NORTH:
			return Vector2i(0, -1)
		DoorDirection.SOUTH:
			return Vector2i(0, 1)
		DoorDirection.EAST:
			return Vector2i(1, 0)
		DoorDirection.WEST:
			return Vector2i(-1, 0)
	return Vector2i.ZERO
