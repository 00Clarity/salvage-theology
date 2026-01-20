extends Node2D

@onready var hud = $HUD
@onready var resource_system = $ResourceSystem
@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player

var current_room_instance: Node2D

func _ready() -> void:
	dungeon_generator.room_entered.connect(_on_room_entered)
	_start_dungeon()

func _start_dungeon() -> void:
	dungeon_generator.generate_dungeon()
	dungeon_generator.enter_room(Vector2i.ZERO)
	_position_player_in_room()

func _on_room_entered(room_data: RoomData) -> void:
	# Update HUD depth
	hud.update_depth(room_data.depth)

	# Disconnect old room signals
	if current_room_instance and is_instance_valid(current_room_instance):
		if current_room_instance.door_entered.is_connected(_on_door_entered):
			current_room_instance.door_entered.disconnect(_on_door_entered)

	# Connect new room signals
	var room_instance = dungeon_generator.get_room_instance(room_data.grid_position)
	if room_instance:
		current_room_instance = room_instance
		if not room_instance.door_entered.is_connected(_on_door_entered):
			room_instance.door_entered.connect(_on_door_entered)

func _on_door_entered(direction: RoomData.DoorDirection) -> void:
	if not dungeon_generator.has_adjacent_room(direction):
		return

	var next_pos = dungeon_generator.get_adjacent_room_position(direction)
	dungeon_generator.enter_room(next_pos)
	_teleport_player_to_door(RoomData.opposite_direction(direction))

func _position_player_in_room() -> void:
	player.global_position = Vector2.ZERO

func _teleport_player_to_door(from_direction: RoomData.DoorDirection) -> void:
	var room_data = dungeon_generator.get_current_room()
	if not room_data:
		return

	var door_pos = room_data.get_door_position(from_direction)
	# Offset player slightly into the room
	var offset = RoomData.direction_to_vector(RoomData.opposite_direction(from_direction))
	player.global_position = door_pos + Vector2(offset) * 48.0

func _on_resource_depleted(resource_name: String) -> void:
	if resource_name == "oxygen":
		resource_system.set_draining(false)
		GameManager.trigger_death()
		hud.show_death_screen()
