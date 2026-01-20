extends CharacterBody2D

@export var move_speed: float = 200.0

# Direction facing (for future animations)
var facing_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")

	if input.length() > 0:
		input = input.normalized()
		facing_direction = input

	velocity = input * move_speed
	move_and_slide()
