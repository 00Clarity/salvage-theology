extends Node

signal game_over
signal game_restarted

enum GameState { PLAYING, DEAD, PAUSED }

var current_state: GameState = GameState.PLAYING
var player: CharacterBody2D

# Door state persistence (Calyx Rule 2: Permanence)
var door_states: Dictionary = {}  # "room_id:door_id" -> TheologyDoor.DoorState

# Run statistics
var current_depth: int = 1
var rooms_visited: int = 0
var items_sacrificed: int = 0
var health_sacrificed: float = 0.0
var memories_sacrificed: int = 0

func _ready() -> void:
	pass

func register_player(p: CharacterBody2D) -> void:
	player = p

func trigger_death() -> void:
	if current_state == GameState.DEAD:
		return
	current_state = GameState.DEAD
	emit_signal("game_over")

func restart_game() -> void:
	current_state = GameState.PLAYING
	_reset_run_stats()
	emit_signal("game_restarted")
	get_tree().reload_current_scene()

func is_playing() -> bool:
	return current_state == GameState.PLAYING

# Door permanence system
func set_door_state(room_id: String, door_id: String, state: int) -> void:
	var key := "%s:%s" % [room_id, door_id]
	door_states[key] = state

func get_door_state(room_id: String, door_id: String) -> int:
	var key := "%s:%s" % [room_id, door_id]
	return door_states.get(key, 0)  # 0 = LOCKED

func is_door_open(room_id: String, door_id: String) -> bool:
	return get_door_state(room_id, door_id) == 2  # 2 = OPEN

# Depth tracking
func set_current_depth(depth: int) -> void:
	current_depth = depth

func get_current_depth() -> int:
	return current_depth

# Statistics tracking
func record_room_visit() -> void:
	rooms_visited += 1

func record_item_sacrifice() -> void:
	items_sacrificed += 1

func record_health_sacrifice(amount: float) -> void:
	health_sacrificed += amount

func record_memory_sacrifice() -> void:
	memories_sacrificed += 1

func _reset_run_stats() -> void:
	current_depth = 1
	rooms_visited = 0
	items_sacrificed = 0
	health_sacrificed = 0.0
	memories_sacrificed = 0
	door_states.clear()

func get_run_summary() -> Dictionary:
	return {
		"depth_reached": current_depth,
		"rooms_visited": rooms_visited,
		"items_sacrificed": items_sacrificed,
		"health_sacrificed": health_sacrificed,
		"memories_sacrificed": memories_sacrificed
	}
