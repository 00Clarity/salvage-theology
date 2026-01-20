extends CharacterBody2D

## Player: Main player character controller
## Handles movement, combat, inventory, health, and material collection

signal item_sacrificed(item_name: String)
signal health_sacrificed(amount: float)
signal memory_sacrificed(memory_name: String)
signal entered_threshold
signal exited_threshold
signal enemy_killed
signal material_collected(material: Node2D)

@export var move_speed: float = 200.0
@export var max_health: float = 100.0
@export var attack_damage: float = 20.0
@export var attack_range: float = 45.0
@export var attack_cooldown: float = 0.4

var health: float = 100.0
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false
var in_threshold: bool = false
var can_attack: bool = true
var is_attacking: bool = false
var invincible: bool = false

# Inventory system
var inventory: Array[String] = ["Scrap Metal", "Faded Cloth"]
var memories: Array[String] = []

# Combat stats
var enemies_killed: int = 0

# Divine material collection
var divine_material_value: int = 0
var corruption_level: float = 0.0
var corruption_rate: float = 0.002  # 0.2% corruption per value point (can be modified by upgrades)

# Base stats (after upgrades, before corruption effects)
var base_move_speed: float = 200.0
var base_attack_damage: float = 20.0

@onready var body: Node2D = $Body

# Attack visual
var attack_arc: Line2D

func _ready() -> void:
	add_to_group("player")

	if not GameManager:
		push_error("[Player] _ready: GameManager autoload not found")
	else:
		GameManager.register_player(self)
		GameManager.apply_upgrades_to_player(self)
		if not GameManager.game_over.is_connected(_on_game_over):
			GameManager.game_over.connect(_on_game_over)

	health = max_health
	_create_attack_visual()

	if not body:
		push_error("[Player] _ready: Body node not found at $Body")

func _create_attack_visual() -> void:
	attack_arc = Line2D.new()
	attack_arc.name = "AttackArc"
	attack_arc.width = 4.0
	attack_arc.default_color = Color("#00ffff", 0.8)
	attack_arc.visible = false
	attack_arc.z_index = 10
	add_child(attack_arc)

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")

	if input.length() > 0:
		input = input.normalized()
		facing_direction = input

	velocity = input * move_speed
	move_and_slide()

func _input(event: InputEvent) -> void:
	if is_dead:
		return

	if event.is_action_pressed("attack") and can_attack:
		perform_attack()

func perform_attack() -> void:
	if not can_attack or is_attacking or in_threshold:
		return

	is_attacking = true
	can_attack = false

	# Show attack visual
	_show_attack_arc()

	# Find enemies in range
	var tree := get_tree()
	if not tree:
		push_error("[Player] perform_attack: SceneTree not available")
		is_attacking = false
		can_attack = true
		return

	var enemies := tree.get_nodes_in_group("echo")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if not enemy.has_method("take_damage"):
			push_warning("[Player] perform_attack: Enemy %s missing take_damage method" % enemy.name)
			continue

		var distance: float = global_position.distance_to(enemy.global_position)
		if distance < attack_range:
			# Check if enemy is in front of player
			var to_enemy: Vector2 = (enemy.global_position - global_position).normalized()
			var dot: float = facing_direction.dot(to_enemy)
			if dot > 0.3:  # Roughly 70 degree cone
				enemy.take_damage(attack_damage)
				if "health" in enemy and enemy.health <= 0:
					enemies_killed += 1
					enemy_killed.emit()
					if GameManager:
						GameManager.record_enemy_killed()

	# Cooldown
	var timer := tree.create_timer(attack_cooldown)
	if timer:
		await timer.timeout
	can_attack = true
	is_attacking = false

func _show_attack_arc() -> void:
	# Create arc in facing direction
	var points := PackedVector2Array()
	var base_angle := facing_direction.angle()
	var arc_range := PI / 2.5  # ~70 degrees

	for i in range(9):
		var t := float(i) / 8.0
		var angle := base_angle - arc_range / 2 + arc_range * t
		points.append(Vector2(cos(angle), sin(angle)) * attack_range)

	attack_arc.points = points
	attack_arc.visible = true

	# Fade out
	var tween := create_tween()
	tween.tween_property(attack_arc, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): attack_arc.visible = false; attack_arc.modulate.a = 1.0)

# Inventory methods
func has_items() -> bool:
	return inventory.size() > 0

func add_item(item_name: String) -> void:
	inventory.append(item_name)

func sacrifice_item() -> String:
	if inventory.is_empty():
		return ""
	var item = inventory.pop_back()
	item_sacrificed.emit(item)
	return item

func get_inventory() -> Array[String]:
	return inventory

# Memory methods
func has_memories() -> bool:
	return memories.size() > 0

func add_memory(memory_name: String) -> void:
	memories.append(memory_name)

func sacrifice_memory() -> String:
	if memories.is_empty():
		return ""
	var memory = memories.pop_back()
	memory_sacrificed.emit(memory)
	return memory

# Health methods
func sacrifice_health(amount: float) -> void:
	health -= amount
	health = max(health, 1.0)
	health_sacrificed.emit(amount)
	_flash_damage()

func take_damage(amount: float) -> void:
	if in_threshold:
		_show_protection_effect()
		return

	if is_dead or invincible:
		return

	if amount < 0:
		push_warning("[Player] take_damage: Negative damage %.2f, using absolute value" % amount)
		amount = absf(amount)

	health -= amount
	_flash_damage()

	# Brief invincibility
	invincible = true
	var tree := get_tree()
	if tree:
		var timer := tree.create_timer(0.5)
		if timer:
			await timer.timeout
	invincible = false

	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)

func _flash_damage() -> void:
	if not body:
		push_warning("[Player] _flash_damage: Body node not available")
		return
	var tween := create_tween()
	if tween:
		tween.tween_property(body, "modulate", Color(1, 0.3, 0.3), 0.1)
		tween.tween_property(body, "modulate", Color.WHITE, 0.2)

func _show_protection_effect() -> void:
	if not body:
		push_warning("[Player] _show_protection_effect: Body node not available")
		return
	var tween := create_tween()
	if tween:
		tween.tween_property(body, "modulate", Color(0, 1, 1, 1.5), 0.1)
		tween.tween_property(body, "modulate", Color.WHITE, 0.2)

# Threshold tracking
func enter_threshold() -> void:
	in_threshold = true
	entered_threshold.emit()

func exit_threshold() -> void:
	in_threshold = false
	exited_threshold.emit()

func is_in_threshold() -> bool:
	return in_threshold

# Death
func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	var tween := create_tween()
	tween.tween_property(body, "modulate:a", 0.3, 0.5)
	tween.parallel().tween_property(body, "scale", Vector2(1.0, 0.5), 0.5)

func _on_game_over() -> void:
	die()

# Divine material collection
func collect_material(material: Node2D) -> void:
	if not material:
		push_warning("[Player] collect_material: Material is null")
		return
	if not is_instance_valid(material):
		push_warning("[Player] collect_material: Material instance is invalid")
		return

	var value: int = material.value if "value" in material else 10
	if value < 0:
		push_warning("[Player] collect_material: Material value is negative (%d), using default 10" % value)
		value = 10
	divine_material_value += value

	# Increase corruption based on material value
	corruption_level += value * corruption_rate
	corruption_level = minf(corruption_level, 1.0)  # Cap at 100%

	_apply_corruption_effects()
	material_collected.emit(material)

	if GameManager:
		GameManager.record_material_collected(value)
	else:
		push_error("[Player] collect_material: GameManager not available")

func _apply_corruption_effects() -> void:
	# Visual corruption - subtle tint toward divine color
	var corruption_color := Color(0.5, 1.0, 1.0, 1.0)  # Cyan tint
	var base_color := Color.WHITE

	if body:
		body.modulate = base_color.lerp(corruption_color, corruption_level * 0.5)
	else:
		push_warning("[Player] _apply_corruption_effects: Body node not available")

	# Corruption affects stats (applies to upgraded base values)
	# Higher corruption = slower movement but stronger attacks
	move_speed = base_move_speed * (1.0 - corruption_level * 0.2)  # Up to 20% slower
	attack_damage = base_attack_damage * (1.0 + corruption_level * 0.5)  # Up to 50% stronger

	# Validate computed values
	if move_speed <= 0:
		push_warning("[Player] _apply_corruption_effects: move_speed became non-positive (%.2f), clamping to 1.0" % move_speed)
		move_speed = 1.0
	if attack_damage <= 0:
		push_warning("[Player] _apply_corruption_effects: attack_damage became non-positive (%.2f), clamping to 1.0" % attack_damage)
		attack_damage = 1.0

func get_corruption_level() -> float:
	return corruption_level

func get_material_value() -> int:
	return divine_material_value

func reset() -> void:
	is_dead = false
	health = max_health
	in_threshold = false
	invincible = false
	can_attack = true
	is_attacking = false
	enemies_killed = 0
	divine_material_value = 0
	corruption_level = 0.0
	corruption_rate = 0.002
	base_move_speed = 200.0
	base_attack_damage = 20.0
	move_speed = 200.0
	attack_damage = 20.0
	body.modulate = Color.WHITE
	body.scale = Vector2.ONE
	inventory = ["Scrap Metal", "Faded Cloth"]
	memories.clear()
