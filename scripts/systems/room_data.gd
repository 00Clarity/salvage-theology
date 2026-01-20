class_name RoomData
extends Resource

# Room types from GODS.md
enum RoomType {
	PASSAGE,   # Simple connector, 1-2 enemies, minimal loot
	CHAMBER,   # Larger room, 3-5 enemies, moderate loot
	VAULT,     # Treasure room, guarded, high loot
	SANCTUM,   # Theology puzzle room
	HAZARD,    # Environmental danger
	REST       # Safe zone, oxygen cache
}

enum DoorDirection { NORTH, SOUTH, EAST, WEST }

# Room dimensions in tiles
@export var width: int = 12
@export var height: int = 10
@export var room_type: RoomType = RoomType.PASSAGE
@export var depth: int = 1
@export var doors: Array[DoorDirection] = []

# Grid position in dungeon layout
var grid_position: Vector2i = Vector2i.ZERO

# Tile size for rendering
const TILE_SIZE: int = 32

# Depth zones from GODS.md
static func get_depth_zone(d: int) -> String:
	if d <= 2:
		return "ENTRY"      # Tutorial, low threat
	elif d <= 5:
		return "OUTER"      # Full theology, standard enemies
	elif d <= 8:
		return "INNER"      # Theology complications, elite enemies
	else:
		return "CORE"       # Maximum danger

# Room type distribution by depth from GODS.md
static func roll_room_type(d: int) -> RoomType:
	var roll = randf()
	var zone = get_depth_zone(d)

	match zone:
		"ENTRY":
			# 50% Passage, 30% Chamber, 10% Vault, 10% Rest
			if roll < 0.5: return RoomType.PASSAGE
			elif roll < 0.8: return RoomType.CHAMBER
			elif roll < 0.9: return RoomType.VAULT
			else: return RoomType.REST
		"OUTER":
			# 30% Passage, 40% Chamber, 15% Vault, 10% Sanctum, 5% Rest
			if roll < 0.3: return RoomType.PASSAGE
			elif roll < 0.7: return RoomType.CHAMBER
			elif roll < 0.85: return RoomType.VAULT
			elif roll < 0.95: return RoomType.SANCTUM
			else: return RoomType.REST
		"INNER":
			# 20% Passage, 30% Chamber, 20% Vault, 20% Sanctum, 10% Hazard
			if roll < 0.2: return RoomType.PASSAGE
			elif roll < 0.5: return RoomType.CHAMBER
			elif roll < 0.7: return RoomType.VAULT
			elif roll < 0.9: return RoomType.SANCTUM
			else: return RoomType.HAZARD
		"CORE":
			# 10% Passage, 30% Chamber, 25% Vault, 25% Sanctum, 10% Hazard
			if roll < 0.1: return RoomType.PASSAGE
			elif roll < 0.4: return RoomType.CHAMBER
			elif roll < 0.65: return RoomType.VAULT
			elif roll < 0.9: return RoomType.SANCTUM
			else: return RoomType.HAZARD

	return RoomType.PASSAGE

func get_pixel_size() -> Vector2:
	return Vector2(width * TILE_SIZE, height * TILE_SIZE)

func get_center() -> Vector2:
	return Vector2.ZERO  # Room is centered at origin

func get_door_world_position(direction: DoorDirection) -> Vector2:
	var half_w = width * TILE_SIZE / 2.0
	var half_h = height * TILE_SIZE / 2.0

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
		DoorDirection.NORTH: return DoorDirection.SOUTH
		DoorDirection.SOUTH: return DoorDirection.NORTH
		DoorDirection.EAST: return DoorDirection.WEST
		DoorDirection.WEST: return DoorDirection.EAST
	return DoorDirection.NORTH

static func direction_to_vector(dir: DoorDirection) -> Vector2i:
	match dir:
		DoorDirection.NORTH: return Vector2i(0, -1)
		DoorDirection.SOUTH: return Vector2i(0, 1)
		DoorDirection.EAST: return Vector2i(1, 0)
		DoorDirection.WEST: return Vector2i(-1, 0)
	return Vector2i.ZERO

static func direction_name(dir: DoorDirection) -> String:
	match dir:
		DoorDirection.NORTH: return "NORTH"
		DoorDirection.SOUTH: return "SOUTH"
		DoorDirection.EAST: return "EAST"
		DoorDirection.WEST: return "WEST"
	return "UNKNOWN"
