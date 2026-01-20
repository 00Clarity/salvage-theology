class_name EchoBase
extends CharacterBody2D

signal player_detected
signal died
signal alert_triggered(position: Vector2)

enum EchoState { IDLE, PATROL, ALERT, CHASE, STARVING, DEAD }

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")

@export var max_health: float = 50.0
@export var speed: float = 50.0
@export var detection_range: float = 150.0
@export var alert_duration: float = 2.0

var health: float = max_health
var current_state: EchoState = EchoState.PATROL
var target_position: Vector2
var alert_timer: float = 0.0
var player_ref: Node2D

# Patrol
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var wait_timer: float = 0.0

func _ready() -> void:
	add_to_group("echo")
	health = max_health
	_setup_visuals()
	_generate_patrol_points()

func _physics_process(delta: float) -> void:
	match current_state:
		EchoState.IDLE:
			_idle_behavior(delta)
		EchoState.PATROL:
			_patrol_behavior(delta)
			_check_for_player()
		EchoState.ALERT:
			_alert_behavior(delta)
		EchoState.CHASE:
			_chase_behavior(delta)
		EchoState.STARVING:
			_starving_behavior(delta)
		EchoState.DEAD:
			pass

func _setup_visuals() -> void:
	# Override in subclass
	pass

func _generate_patrol_points() -> void:
	# Generate random patrol points around spawn position
	var spawn_pos := global_position
	for i in range(3):
		var angle := randf() * TAU
		var dist := randf_range(50, 150)
		patrol_points.append(spawn_pos + Vector2(cos(angle), sin(angle)) * dist)

func _idle_behavior(delta: float) -> void:
	wait_timer -= delta
	if wait_timer <= 0:
		current_state = EchoState.PATROL

func _patrol_behavior(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var target := patrol_points[current_patrol_index]
	var direction := (target - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(target) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		wait_timer = randf_range(0.5, 2.0)
		current_state = EchoState.IDLE

func _check_for_player() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref:
		return

	var distance := global_position.distance_to(player_ref.global_position)
	if distance < detection_range:
		if _can_see_player():
			_enter_alert_state()

func _can_see_player() -> bool:
	if not player_ref:
		return false

	# Raycast to check line of sight
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player_ref.global_position,
		1  # Collision mask for walls
	)
	query.exclude = [self]

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.collider == player_ref or result.collider.is_in_group("player")

func _enter_alert_state() -> void:
	current_state = EchoState.ALERT
	alert_timer = alert_duration
	_show_alert_visual()
	player_detected.emit()

func _alert_behavior(delta: float) -> void:
	alert_timer -= delta

	if not _can_see_player():
		_return_to_patrol()
		return

	if alert_timer <= 0:
		_trigger_full_alert()

func _trigger_full_alert() -> void:
	current_state = EchoState.CHASE
	alert_triggered.emit(player_ref.global_position if player_ref else global_position)

	# Alert all echoes in room
	for echo in get_tree().get_nodes_in_group("echo"):
		if echo != self and echo.has_method("on_player_alert"):
			echo.on_player_alert(player_ref.global_position if player_ref else global_position)

func _chase_behavior(delta: float) -> void:
	if not player_ref or not is_instance_valid(player_ref):
		_return_to_patrol()
		return

	var direction := (player_ref.global_position - global_position).normalized()
	velocity = direction * speed * 1.5
	move_and_slide()

func _starving_behavior(_delta: float) -> void:
	# Vorath theology: starving enemies retreat
	if target_position != Vector2.ZERO:
		var direction := (target_position - global_position).normalized()
		velocity = direction * speed * 0.5
		move_and_slide()

func _return_to_patrol() -> void:
	current_state = EchoState.PATROL
	_hide_alert_visual()

func _show_alert_visual() -> void:
	# Override in subclass
	pass

func _hide_alert_visual() -> void:
	# Override in subclass
	pass

func on_player_alert(player_pos: Vector2) -> void:
	if current_state != EchoState.CHASE and current_state != EchoState.DEAD:
		target_position = player_pos
		current_state = EchoState.CHASE

func take_damage(amount: float) -> void:
	health -= amount
	_flash_damage()

	if health <= 0:
		die()
	elif health <= max_health * 0.2:
		_enter_starving_state()

func _enter_starving_state() -> void:
	current_state = EchoState.STARVING
	modulate = Color(1, 1, 0.5)  # Yellow tint
	target_position = _find_retreat_point()

func _find_retreat_point() -> Vector2:
	if not player_ref:
		return global_position

	var away_dir := (global_position - player_ref.global_position).normalized()
	return global_position + away_dir * 200

func _flash_damage() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func die() -> void:
	if current_state == EchoState.DEAD:
		return

	current_state = EchoState.DEAD
	died.emit()
	_play_death_effect()
	_drop_loot()

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _play_death_effect() -> void:
	# Override in subclass
	pass

func _drop_loot() -> void:
	# Will be implemented in Phase 7
	pass
