extends CharacterBody2D

@export var move_speed: float = 200.0

# Direction facing (for future animations)
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false

@onready var body: Node2D = $Body

func _ready() -> void:
	add_to_group("player")
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

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	# Visual death effect - fade out and collapse
	var tween := create_tween()
	tween.tween_property(body, "modulate:a", 0.3, 0.5)
	tween.parallel().tween_property(body, "scale", Vector2(1.0, 0.5), 0.5)

func _on_game_over() -> void:
	die()
