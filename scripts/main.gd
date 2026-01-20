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
	_position_player_at_center()

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

	# Position player at the entry door (opposite direction they came from)
	var entry_direction = RoomData.opposite_direction(direction)
	var entry_pos = dungeon_generator.get_door_entry_position(entry_direction)
	player.global_position = entry_pos

func _position_player_at_center() -> void:
	player.global_position = Vector2.ZERO

func _on_resource_depleted(resource_name: String) -> void:
	if resource_name == "oxygen":
		resource_system.set_draining(false)
		GameManager.trigger_death()
		hud.show_death_screen()
