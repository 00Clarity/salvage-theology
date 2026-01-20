extends Node2D

## Main: Game scene controller for dungeon runs
## Manages player, HUD, resources, rooms, and game flow

const PaymentMenuScene := preload("res://scenes/ui/payment_menu.tscn")
const RunSummaryScene := preload("res://scenes/ui/run_summary.tscn")

@onready var hud = $HUD
@onready var resource_system = $ResourceSystem
@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player

var current_room_instance: Node2D
var payment_menu: PaymentMenu
var run_summary: RunSummary

func _ready() -> void:
	# Validate required nodes
	if not hud:
		push_error("[Main] _ready: HUD node not found")
	if not resource_system:
		push_error("[Main] _ready: ResourceSystem node not found")
	if not dungeon_generator:
		push_error("[Main] _ready: DungeonGenerator node not found")
	if not player:
		push_error("[Main] _ready: Player node not found")

	# Connect signals with validation
	if dungeon_generator:
		if dungeon_generator.has_signal("room_entered"):
			dungeon_generator.room_entered.connect(_on_room_entered)
		else:
			push_error("[Main] _ready: DungeonGenerator missing room_entered signal")

	if resource_system:
		if resource_system.has_signal("resource_depleted"):
			resource_system.resource_depleted.connect(_on_resource_depleted)
		else:
			push_error("[Main] _ready: ResourceSystem missing resource_depleted signal")

		if resource_system.has_signal("resource_changed") and hud and hud.has_method("_on_resource_changed"):
			resource_system.resource_changed.connect(hud._on_resource_changed)
		else:
			push_warning("[Main] _ready: Could not connect resource_changed to HUD")

	_apply_oxygen_upgrades()
	_setup_payment_menu()
	_setup_run_summary()
	_start_dungeon()

func _apply_oxygen_upgrades() -> void:
	if not GameManager:
		push_error("[Main] _apply_oxygen_upgrades: GameManager not available")
		return
	if not resource_system:
		push_error("[Main] _apply_oxygen_upgrades: ResourceSystem not available")
		return

	var oxygen_level: int = GameManager.get_upgrade_level("oxygen_capacity")
	if oxygen_level > 0:
		resource_system.max_oxygen = 100.0 * (1.0 + oxygen_level * 0.2)
		resource_system.oxygen = resource_system.max_oxygen

func _setup_payment_menu() -> void:
	if not PaymentMenuScene:
		push_error("[Main] _setup_payment_menu: PaymentMenuScene not loaded")
		return

	payment_menu = PaymentMenuScene.instantiate()
	if not payment_menu:
		push_error("[Main] _setup_payment_menu: Failed to instantiate PaymentMenu")
		return

	payment_menu.payment_selected.connect(_on_payment_made)
	payment_menu.payment_cancelled.connect(_on_payment_cancelled)
	add_child(payment_menu)

func _setup_run_summary() -> void:
	if not RunSummaryScene:
		push_error("[Main] _setup_run_summary: RunSummaryScene not loaded")
		return

	run_summary = RunSummaryScene.instantiate()
	if not run_summary:
		push_error("[Main] _setup_run_summary: Failed to instantiate RunSummary")
		return

	run_summary.restart_pressed.connect(_on_run_restart)
	run_summary.continue_pressed.connect(_on_continue_to_station)
	add_child(run_summary)

func _start_dungeon() -> void:
	if not dungeon_generator:
		push_error("[Main] _start_dungeon: DungeonGenerator not available")
		return

	dungeon_generator.generate_dungeon()
	dungeon_generator.enter_room(Vector2i.ZERO)
	_position_player_at_center()

func _on_room_entered(room_data: RoomData) -> void:
	if not room_data:
		push_error("[Main] _on_room_entered: room_data is null")
		return

	if hud and hud.has_method("update_depth"):
		hud.update_depth(room_data.depth)
	else:
		push_warning("[Main] _on_room_entered: HUD missing update_depth method")

	if GameManager:
		GameManager.set_current_depth(room_data.depth)
		GameManager.record_room_visit()
	else:
		push_error("[Main] _on_room_entered: GameManager not available")

	# Disconnect old room signals
	if current_room_instance and is_instance_valid(current_room_instance):
		_disconnect_room_signals(current_room_instance)

	# Connect new room signals
	if not dungeon_generator:
		push_error("[Main] _on_room_entered: DungeonGenerator not available")
		return

	var room_instance = dungeon_generator.get_room_instance(room_data.grid_position)
	if room_instance:
		current_room_instance = room_instance
		_connect_room_signals(room_instance)
	else:
		push_warning("[Main] _on_room_entered: No room instance at position %s" % room_data.grid_position)

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
	if not dungeon_generator:
		push_error("[Main] _on_door_entered: DungeonGenerator not available")
		return

	if not dungeon_generator.has_adjacent_room(direction):
		return

	var next_pos = dungeon_generator.get_adjacent_room_position(direction)
	dungeon_generator.enter_room(next_pos)

	var entry_direction = RoomData.opposite_direction(direction)
	var entry_pos = dungeon_generator.get_door_entry_position(entry_direction)

	if player:
		player.global_position = entry_pos
	else:
		push_error("[Main] _on_door_entered: Player not available")

func _on_door_payment_requested(door: TheologyDoor) -> void:
	if not door:
		push_error("[Main] _on_door_payment_requested: door is null")
		return
	if not payment_menu:
		push_error("[Main] _on_door_payment_requested: PaymentMenu not available")
		return
	payment_menu.show_menu(door)

func _on_payment_made(payment_type: TheologyDoor.PaymentType) -> void:
	if not GameManager:
		push_error("[Main] _on_payment_made: GameManager not available")
		return

	match payment_type:
		TheologyDoor.PaymentType.ITEM:
			GameManager.record_item_sacrifice()
		TheologyDoor.PaymentType.HEALTH:
			if player:
				GameManager.record_health_sacrifice(player.max_health * 0.1)
			else:
				push_error("[Main] _on_payment_made: Player not available for health sacrifice")
		TheologyDoor.PaymentType.MEMORY:
			GameManager.record_memory_sacrifice()

func _on_payment_cancelled() -> void:
	if not player:
		push_error("[Main] _on_payment_cancelled: Player not available")
		return
	# Player chose not to pay - push them back slightly
	var push_direction = -player.facing_direction.normalized()
	player.global_position += push_direction * 32

func _position_player_at_center() -> void:
	if player:
		player.global_position = Vector2.ZERO
	else:
		push_error("[Main] _position_player_at_center: Player not available")

func _on_resource_depleted(resource_name: String) -> void:
	if resource_name == "oxygen":
		if resource_system:
			resource_system.set_draining(false)
		else:
			push_warning("[Main] _on_resource_depleted: ResourceSystem not available")

		if GameManager:
			GameManager.trigger_death()
		else:
			push_error("[Main] _on_resource_depleted: GameManager not available")
		# Death screen now handled by run_summary

func _on_run_restart() -> void:
	# Handled by run_summary calling GameManager.restart_game()
	pass

func _on_continue_to_station() -> void:
	if GameManager:
		GameManager.save_game()
	else:
		push_error("[Main] _on_continue_to_station: GameManager not available, progress may be lost")

	var tree := get_tree()
	if tree:
		var error := tree.change_scene_to_file("res://scenes/station/station.tscn")
		if error != OK:
			push_error("[Main] _on_continue_to_station: Failed to change scene (error: %d)" % error)
	else:
		push_error("[Main] _on_continue_to_station: SceneTree not available")
