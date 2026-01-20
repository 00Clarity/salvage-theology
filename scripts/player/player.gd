extends CharacterBody2D

signal item_sacrificed(item_name: String)
signal health_sacrificed(amount: float)
signal memory_sacrificed(memory_name: String)
signal entered_threshold
signal exited_threshold

@export var move_speed: float = 200.0
@export var max_health: float = 100.0

var health: float = 100.0
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false
var in_threshold: bool = false

# Inventory system (simplified for Phase 4)
var inventory: Array[String] = ["Scrap Metal", "Faded Cloth"]
var memories: Array[String] = []

@onready var body: Node2D = $Body

func _ready() -> void:
	add_to_group("player")
	health = max_health
	GameManager.register_player(self)
	GameManager.game_over.connect(_on_game_over)

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

	if is_dead:
		return

	health -= amount
	_flash_damage()

	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)

func _flash_damage() -> void:
	var tween := create_tween()
	tween.tween_property(body, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(body, "modulate", Color.WHITE, 0.2)

func _show_protection_effect() -> void:
	var tween := create_tween()
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

func reset() -> void:
	is_dead = false
	health = max_health
	in_threshold = false
	body.modulate = Color.WHITE
	body.scale = Vector2.ONE
	inventory = ["Scrap Metal", "Faded Cloth"]
	memories.clear()
