class_name EchoSeeker
extends EchoBase

# Seeker-specific properties
var trail: Line2D
var trail_points: Array[Vector2] = []
const MAX_TRAIL := 15
var body: Polygon2D
var eye: Polygon2D
var attack_cooldown: float = 0.0
var dash_timer: float = 0.0
var is_dashing: bool = false

@export var attack_damage: float = 15.0
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.5

func _ready() -> void:
	# Override defaults for Seeker
	max_health = 40.0
	speed = 60.0
	detection_range = 200.0
	alert_duration = 0.5  # Quick to aggro

	super._ready()

func _setup_visuals() -> void:
	_create_body()
	_create_eye()
	_create_trail()
	_create_glow()
	_create_collision()

func _create_body() -> void:
	body = Polygon2D.new()
	body.name = "Body"
	body.polygon = PackedVector2Array([
		Vector2(0, -20),
		Vector2(-14, 16),
		Vector2(14, 16)
	])
	body.color = Color(CALYX_CYAN, 0.9)
	body.z_index = 1
	add_child(body)

	# Inner triangle
	var inner := Polygon2D.new()
	inner.name = "Inner"
	inner.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(-8, 10),
		Vector2(8, 10)
	])
	inner.color = Color(0, 0.3, 0.3)
	body.add_child(inner)

	# Edge lines
	var edge := Line2D.new()
	edge.points = PackedVector2Array([
		Vector2(0, -20),
		Vector2(-14, 16),
		Vector2(14, 16),
		Vector2(0, -20)
	])
	edge.width = 2.0
	edge.default_color = CALYX_CYAN
	body.add_child(edge)

func _create_eye() -> void:
	eye = Polygon2D.new()
	eye.name = "Eye"
	var points := PackedVector2Array()
	for i in range(10):
		var angle := i * TAU / 10
		points.append(Vector2(cos(angle), sin(angle)) * 5)
	eye.polygon = points
	eye.color = Color.WHITE
	eye.position = Vector2(0, 2)
	eye.z_index = 2
	add_child(eye)

	# Pupil
	var pupil := Polygon2D.new()
	var pupil_points := PackedVector2Array()
	for i in range(8):
		var angle := i * TAU / 8
		pupil_points.append(Vector2(cos(angle), sin(angle)) * 2)
	pupil.polygon = pupil_points
	pupil.color = Color.BLACK
	eye.add_child(pupil)

func _create_trail() -> void:
	trail = Line2D.new()
	trail.name = "Trail"
	trail.width = 10.0
	trail.z_index = 0

	# Width curve (wide at start, thin at end)
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	trail.width_curve = curve

	# Gradient color
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(CALYX_CYAN, 0.8), Color(CALYX_CYAN, 0.0)])
	trail.gradient = gradient

	add_child(trail)

func _create_glow() -> void:
	var light := PointLight2D.new()
	light.color = CALYX_CYAN
	light.energy = 0.5
	light.texture_scale = 0.6
	_setup_light_texture(light)
	add_child(light)

func _create_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	collision.shape = shape
	add_child(collision)

	# Hitbox for damaging player
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	var hitbox_shape := CollisionShape2D.new()
	var hitbox_circle := CircleShape2D.new()
	hitbox_circle.radius = 16.0
	hitbox_shape.shape = hitbox_circle
	hitbox.add_child(hitbox_shape)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	add_child(hitbox)

func _setup_light_texture(light: PointLight2D) -> void:
	var gradient := GradientTexture2D.new()
	gradient.width = 128
	gradient.height = 128
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color.TRANSPARENT])
	gradient.gradient = grad
	light.texture = gradient

func _physics_process(delta: float) -> void:
	attack_cooldown -= delta
	dash_timer -= delta

	if is_dashing:
		_dash_behavior(delta)
	else:
		super._physics_process(delta)

	_update_trail()
	_update_rotation()

func _chase_behavior(delta: float) -> void:
	if not player_ref or not is_instance_valid(player_ref):
		_return_to_patrol()
		return

	var distance := global_position.distance_to(player_ref.global_position)

	# Start dash when close enough and cooldown ready
	if distance < 100 and dash_timer <= 0 and not is_dashing:
		_start_dash()
		return

	# Normal chase
	var direction := (player_ref.global_position - global_position).normalized()
	velocity = direction * speed * 1.5
	move_and_slide()

func _start_dash() -> void:
	if not player_ref:
		return

	is_dashing = true
	dash_timer = dash_duration

	var direction := (player_ref.global_position - global_position).normalized()
	velocity = direction * dash_speed

	# Visual feedback
	var tween := create_tween()
	tween.tween_property(body, "modulate", Color(1, 1, 1, 1.5), 0.1)

func _dash_behavior(_delta: float) -> void:
	move_and_slide()

	if dash_timer <= 0:
		is_dashing = false
		dash_timer = dash_cooldown
		body.modulate = Color.WHITE

func _update_trail() -> void:
	trail_points.insert(0, global_position)
	if trail_points.size() > MAX_TRAIL:
		trail_points.pop_back()

	# Convert to local coordinates
	var local_points := PackedVector2Array()
	for point in trail_points:
		local_points.append(point - global_position)
	trail.points = local_points

func _update_rotation() -> void:
	if velocity.length() > 1:
		rotation = velocity.angle() + PI / 2

func _on_hitbox_body_entered(body_node: Node2D) -> void:
	if body_node.is_in_group("player") and attack_cooldown <= 0:
		if body_node.has_method("take_damage"):
			body_node.take_damage(attack_damage)
			attack_cooldown = 0.5

			# Knockback effect on self
			var knockback := (global_position - body_node.global_position).normalized()
			velocity = knockback * 100

func _show_alert_visual() -> void:
	var tween := create_tween()
	tween.tween_property(body, "modulate", Color("#ff6600"), 0.1)
	tween.tween_property(body, "modulate", Color.WHITE, 0.1)

func _hide_alert_visual() -> void:
	body.modulate = Color.WHITE

func _play_death_effect() -> void:
	# Explode outward
	var tween := create_tween()
	tween.parallel().tween_property(body, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(body, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(trail, "modulate:a", 0.0, 0.2)
