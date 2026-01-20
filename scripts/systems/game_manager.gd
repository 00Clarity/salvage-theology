extends Node

signal game_over
signal game_restarted
signal extraction_complete(summary: Dictionary)

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
var material_collected: int = 0
var enemies_killed: int = 0

# Meta-progression (persists across runs)
var total_material_banked: int = 0
var runs_completed: int = 0
var upgrade_levels: Dictionary = {}  # upgrade_id -> level

const SAVE_PATH := "user://salvage_theology_save.dat"

func _ready() -> void:
	load_game()

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

func record_material_collected(value: int) -> void:
	material_collected += value

func record_enemy_killed() -> void:
	enemies_killed += 1

func complete_extraction() -> void:
	# Bank the material from this run
	total_material_banked += material_collected
	runs_completed += 1

	var summary := get_run_summary()
	extraction_complete.emit(summary)

func _reset_run_stats() -> void:
	current_depth = 1
	rooms_visited = 0
	items_sacrificed = 0
	health_sacrificed = 0.0
	memories_sacrificed = 0
	material_collected = 0
	enemies_killed = 0
	door_states.clear()

func get_run_summary() -> Dictionary:
	return {
		"depth_reached": current_depth,
		"rooms_visited": rooms_visited,
		"items_sacrificed": items_sacrificed,
		"health_sacrificed": health_sacrificed,
		"memories_sacrificed": memories_sacrificed,
		"material_collected": material_collected,
		"enemies_killed": enemies_killed,
		"total_banked": total_material_banked,
		"runs_completed": runs_completed
	}

func get_total_banked() -> int:
	return total_material_banked

# Upgrade system
func set_upgrade_level(upgrade_id: String, level: int) -> void:
	upgrade_levels[upgrade_id] = level

func get_upgrade_level(upgrade_id: String) -> int:
	return upgrade_levels.get(upgrade_id, 0)

func get_all_upgrades() -> Dictionary:
	return upgrade_levels.duplicate()

func apply_upgrades_to_player(p: CharacterBody2D) -> void:
	# Apply permanent upgrades to player at run start
	var health_level: int = get_upgrade_level("health_boost")
	p.max_health = 100.0 + health_level * 25.0
	p.health = p.max_health

	var attack_level: int = get_upgrade_level("attack_power")
	p.attack_damage = 20.0 * (1.0 + attack_level * 0.1)

	var speed_level: int = get_upgrade_level("move_speed")
	p.move_speed = 200.0 * (1.0 + speed_level * 0.1)

	# Corruption resistance
	var corruption_resist_level: int = get_upgrade_level("corruption_resist")
	p.corruption_rate = 0.002 * (1.0 - corruption_resist_level * 0.2)  # 20% reduction per level

	# Starting items
	var item_level: int = get_upgrade_level("starting_items")
	for i in range(item_level):
		p.add_item("Salvaged Component")

# Save/Load system
func save_game() -> void:
	var save_data := {
		"total_material_banked": total_material_banked,
		"runs_completed": runs_completed,
		"upgrade_levels": upgrade_levels
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data: Variant = file.get_var()
		file.close()

		if save_data is Dictionary:
			total_material_banked = save_data.get("total_material_banked", 0)
			runs_completed = save_data.get("runs_completed", 0)
			upgrade_levels = save_data.get("upgrade_levels", {})

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
