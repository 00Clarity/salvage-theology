extends Node2D

const PaymentMenuScene := preload("res://scenes/ui/payment_menu.tscn")

@onready var hud = $HUD
@onready var resource_system = $ResourceSystem
@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player

var current_room_instance: Node2D
var payment_menu: PaymentMenu

func _ready() -> void:
	dungeon_generator.room_entered.connect(_on_room_entered)
	_setup_payment_menu()
	_start_dungeon()

func _setup_payment_menu() -> void:
	payment_menu = PaymentMenuScene.instantiate()
	payment_menu.payment_selected.connect(_on_payment_made)
	payment_menu.payment_cancelled.connect(_on_payment_cancelled)
	add_child(payment_menu)

func _start_dungeon() -> void:
	dungeon_generator.generate_dungeon()
	dungeon_generator.enter_room(Vector2i.ZERO)
	_position_player_at_center()

func _on_room_entered(room_data: RoomData) -> void:
	hud.update_depth(room_data.depth)
	GameManager.set_current_depth(room_data.depth)
	GameManager.record_room_visit()

	# Disconnect old room signals
	if current_room_instance and is_instance_valid(current_room_instance):
		_disconnect_room_signals(current_room_instance)

	# Connect new room signals
	var room_instance = dungeon_generator.get_room_instance(room_data.grid_position)
	if room_instance:
		current_room_instance = room_instance
		_connect_room_signals(room_instance)

func _connect_room_signals(room: Node2D) -> void:
	if not room.door_entered.is_connected(_on_door_entered):
		room.door_entered.connect(_on_door_entered)
	if room.has_signal("door_payment_requested"):
		if not room.door_payment_requested.is_connected(_on_door_payment_requested):
			room.door_payment_requested.connect(_on_door_payment_requested)

func _disconnect_room_signals(room: Node2D) -> void:
	if room.door_entered.is_connected(_on_door_entered):
		room.door_entered.disconnect(_on_door_entered)
	if room.has_signal("door_payment_requested"):
		if room.door_payment_requested.is_connected(_on_door_payment_requested):
			room.door_payment_requested.disconnect(_on_door_payment_requested)

func _on_door_entered(direction: RoomData.DoorDirection) -> void:
	if not dungeon_generator.has_adjacent_room(direction):
		return

	var next_pos = dungeon_generator.get_adjacent_room_position(direction)
	dungeon_generator.enter_room(next_pos)

	var entry_direction = RoomData.opposite_direction(direction)
	var entry_pos = dungeon_generator.get_door_entry_position(entry_direction)
	player.global_position = entry_pos

func _on_door_payment_requested(door: TheologyDoor) -> void:
	payment_menu.show_menu(door)

func _on_payment_made(payment_type: TheologyDoor.PaymentType) -> void:
	match payment_type:
		TheologyDoor.PaymentType.ITEM:
			GameManager.record_item_sacrifice()
		TheologyDoor.PaymentType.HEALTH:
			GameManager.record_health_sacrifice(player.max_health * 0.1)
		TheologyDoor.PaymentType.MEMORY:
			GameManager.record_memory_sacrifice()

func _on_payment_cancelled() -> void:
	# Player chose not to pay - push them back slightly
	var push_direction = -player.facing_direction.normalized()
	player.global_position += push_direction * 32

func _position_player_at_center() -> void:
	player.global_position = Vector2.ZERO

func _on_resource_depleted(resource_name: String) -> void:
	if resource_name == "oxygen":
		resource_system.set_draining(false)
		GameManager.trigger_death()
		hud.show_death_screen()
