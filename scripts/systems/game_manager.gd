extends Node

## GameManager: Central game state and persistence controller
## Handles player registration, game state, door persistence, stats, and save/load

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
	if not p:
		push_error("[GameManager] register_player: Attempted to register null player")
		return
	if not is_instance_valid(p):
		push_error("[GameManager] register_player: Player instance is invalid")
		return
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
	if amount < 0:
		push_warning("[GameManager] record_health_sacrifice: Negative amount %.2f, using absolute value" % amount)
		amount = absf(amount)
	health_sacrificed += amount

func record_memory_sacrifice() -> void:
	memories_sacrificed += 1

func record_material_collected(value: int) -> void:
	if value < 0:
		push_warning("[GameManager] record_material_collected: Negative value %d, ignoring" % value)
		return
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
	if not p:
		push_error("[GameManager] apply_upgrades_to_player: Player is null")
		return
	if not is_instance_valid(p):
		push_error("[GameManager] apply_upgrades_to_player: Player instance is invalid")
		return

	# Apply permanent upgrades to player at run start
	var health_level: int = get_upgrade_level("health_boost")
	if health_level < 0:
		push_warning("[GameManager] apply_upgrades_to_player: Invalid health_boost level %d, clamping to 0" % health_level)
		health_level = 0
	p.max_health = 100.0 + health_level * 25.0
	p.health = p.max_health

	var attack_level: int = get_upgrade_level("attack_power")
	if attack_level < 0:
		push_warning("[GameManager] apply_upgrades_to_player: Invalid attack_power level %d, clamping to 0" % attack_level)
		attack_level = 0
	p.base_attack_damage = 20.0 * (1.0 + attack_level * 0.1)
	p.attack_damage = p.base_attack_damage

	var speed_level: int = get_upgrade_level("move_speed")
	if speed_level < 0:
		push_warning("[GameManager] apply_upgrades_to_player: Invalid move_speed level %d, clamping to 0" % speed_level)
		speed_level = 0
	p.base_move_speed = 200.0 * (1.0 + speed_level * 0.1)
	p.move_speed = p.base_move_speed

	# Corruption resistance (caps at 75% reduction at level 5)
	var corruption_resist_level: int = get_upgrade_level("corruption_resist")
	if corruption_resist_level < 0:
		push_warning("[GameManager] apply_upgrades_to_player: Invalid corruption_resist level %d, clamping to 0" % corruption_resist_level)
		corruption_resist_level = 0
	p.corruption_rate = 0.002 * maxf(0.25, 1.0 - corruption_resist_level * 0.15)  # 15% reduction per level, max 75%

	# Starting items
	var item_level: int = get_upgrade_level("starting_items")
	if item_level < 0:
		push_warning("[GameManager] apply_upgrades_to_player: Invalid starting_items level %d, clamping to 0" % item_level)
		item_level = 0
	for i in range(item_level):
		if p.has_method("add_item"):
			p.add_item("Salvaged Component")
		else:
			push_error("[GameManager] apply_upgrades_to_player: Player missing add_item method")

# Save/Load system
func save_game() -> void:
	var save_data := {
		"total_material_banked": total_material_banked,
		"runs_completed": runs_completed,
		"upgrade_levels": upgrade_levels
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		var error_code := FileAccess.get_open_error()
		push_error("[GameManager] save_game: Failed to open save file at %s (error: %d)" % [SAVE_PATH, error_code])
		return
	file.store_var(save_data)
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return  # No save file is normal for first run

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		var error_code := FileAccess.get_open_error()
		push_error("[GameManager] load_game: Failed to open save file at %s (error: %d)" % [SAVE_PATH, error_code])
		return

	var save_data: Variant = file.get_var()
	file.close()

	if save_data == null:
		push_error("[GameManager] load_game: Save data is null, file may be corrupted")
		return

	if not save_data is Dictionary:
		push_error("[GameManager] load_game: Save data is not a Dictionary (type: %s)" % typeof(save_data))
		return

	total_material_banked = save_data.get("total_material_banked", 0)
	runs_completed = save_data.get("runs_completed", 0)
	upgrade_levels = save_data.get("upgrade_levels", {})

	# Validate loaded data
	if total_material_banked < 0:
		push_warning("[GameManager] load_game: Invalid total_material_banked %d, resetting to 0" % total_material_banked)
		total_material_banked = 0
	if runs_completed < 0:
		push_warning("[GameManager] load_game: Invalid runs_completed %d, resetting to 0" % runs_completed)
		runs_completed = 0

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
