class_name EchoWatcher
extends EchoBase

# Watcher-specific properties
var ring_rotation: float = 0.0
var ring: Line2D
var eye: Node2D
var pupil: Polygon2D
var glow_light: PointLight2D
var alert_indicator: Polygon2D

func _ready() -> void:
	# Override defaults for Watcher
	max_health = 30.0
	speed = 30.0  # Slow drift
	detection_range = 180.0
	alert_duration = 2.0

	super._ready()

func _setup_visuals() -> void:
	_create_ring()
	_create_eye()
	_create_glow()
	_create_alert_indicator()
	_create_collision()

func _create_ring() -> void:
	ring = Line2D.new()
	ring.name = "Ring"

	var points := PackedVector2Array()
	for i in range(33):
		var angle := i * TAU / 32
		points.append(Vector2(cos(angle), sin(angle)) * 24)

	ring.points = points
	ring.width = 3.0
	ring.default_color = CALYX_CYAN
	ring.z_index = 1
	add_child(ring)

	# Inner ring
	var inner_ring := Line2D.new()
	inner_ring.name = "InnerRing"
	var inner_points := PackedVector2Array()
	for i in range(33):
		var angle := i * TAU / 32
		inner_points.append(Vector2(cos(angle), sin(angle)) * 20)
	inner_ring.points = inner_points
	inner_ring.width = 1.5
	inner_ring.default_color = Color(CALYX_TEAL, 0.5)
	ring.add_child(inner_ring)

func _create_eye() -> void:
	eye = Node2D.new()
	eye.name = "Eye"
	add_child(eye)

	# Eye white
	var eye_white := Polygon2D.new()
	var white_points := PackedVector2Array()
	for i in range(16):
		var angle := i * TAU / 16
		white_points.append(Vector2(cos(angle), sin(angle)) * 10)
	eye_white.polygon = white_points
	eye_white.color = Color.WHITE
	eye.add_child(eye_white)

	# Pupil
	pupil = Polygon2D.new()
	pupil.name = "Pupil"
	var pupil_points := PackedVector2Array()
	for i in range(12):
		var angle := i * TAU / 12
		pupil_points.append(Vector2(cos(angle), sin(angle)) * 4)
	pupil.polygon = pupil_points
	pupil.color = Color.BLACK
	eye.add_child(pupil)

	# Iris ring
	var iris := Line2D.new()
	var iris_points := PackedVector2Array()
	for i in range(13):
		var angle := i * TAU / 12
		iris_points.append(Vector2(cos(angle), sin(angle)) * 6)
	iris.points = iris_points
	iris.width = 1.5
	iris.default_color = CALYX_CYAN
	eye.add_child(iris)

func _create_glow() -> void:
	glow_light = PointLight2D.new()
	glow_light.color = CALYX_CYAN
	glow_light.energy = 0.6
	glow_light.texture_scale = 0.8
	_setup_light_texture(glow_light)
	add_child(glow_light)

func _create_alert_indicator() -> void:
	# Triangle above the Watcher that appears during alert
	alert_indicator = Polygon2D.new()
	alert_indicator.name = "AlertIndicator"
	alert_indicator.polygon = PackedVector2Array([
		Vector2(0, -40),
		Vector2(-8, -28),
		Vector2(8, -28)
	])
	alert_indicator.color = Color("#ff6600")
	alert_indicator.visible = false
	alert_indicator.z_index = 2
	add_child(alert_indicator)

func _create_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20.0
	collision.shape = shape
	add_child(collision)

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
	super._physics_process(delta)

	# Rotate ring
	ring_rotation += delta * 0.5
	ring.rotation = ring_rotation

	# Eye tracks player
	_track_player()

	# Update alert visual
	if current_state == EchoState.ALERT:
		_pulse_alert_indicator(delta)

func _track_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var dir := (player.global_position - global_position).normalized()
		pupil.position = dir * 4
	else:
		pupil.position = Vector2.ZERO

func _pulse_alert_indicator(delta: float) -> void:
	var pulse := 0.5 + sin(alert_timer * 8) * 0.5
	alert_indicator.modulate.a = pulse

func _show_alert_visual() -> void:
	alert_indicator.visible = true

	# Flash the ring
	var tween := create_tween()
	tween.tween_property(ring, "default_color", Color("#ff6600"), 0.2)
	tween.tween_property(ring, "default_color", CALYX_CYAN, 0.2)
	tween.set_loops(3)

	# Increase glow
	glow_light.energy = 1.0

func _hide_alert_visual() -> void:
	alert_indicator.visible = false
	glow_light.energy = 0.6
	ring.default_color = CALYX_CYAN

func _play_death_effect() -> void:
	# Expand and fade ring
	var tween := create_tween()
	tween.parallel().tween_property(ring, "scale", Vector2(2, 2), 0.5)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(eye, "scale", Vector2(0, 0), 0.3)
	tween.parallel().tween_property(glow_light, "energy", 0.0, 0.5)
