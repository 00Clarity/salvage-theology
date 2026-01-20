class_name ExtractionPoint
extends Area2D

signal extraction_started(point: ExtractionPoint)

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")

@export var extraction_time: float = 2.0  # Seconds to extract

var is_extracting: bool = false
var extraction_progress: float = 0.0
var player_in_range: bool = false

var outer_ring: Line2D
var inner_ring: Line2D
var center_polygon: Polygon2D
var progress_ring: Line2D
var glow_light: PointLight2D
var pulse_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_create_visual()
	_create_collision()

func _create_visual() -> void:
	# Outer ring - diamond shape
	outer_ring = Line2D.new()
	var outer_points := PackedVector2Array([
		Vector2(0, -40),
		Vector2(40, 0),
		Vector2(0, 40),
		Vector2(-40, 0),
		Vector2(0, -40)
	])
	outer_ring.points = outer_points
	outer_ring.width = 3.0
	outer_ring.default_color = CALYX_CYAN
	outer_ring.z_index = 5
	add_child(outer_ring)

	# Inner ring - smaller diamond
	inner_ring = Line2D.new()
	var inner_points := PackedVector2Array([
		Vector2(0, -24),
		Vector2(24, 0),
		Vector2(0, 24),
		Vector2(-24, 0),
		Vector2(0, -24)
	])
	inner_ring.points = inner_points
	inner_ring.width = 2.0
	inner_ring.default_color = Color(CALYX_TEAL, 0.8)
	inner_ring.z_index = 5
	add_child(inner_ring)

	# Center polygon - up arrow
	center_polygon = Polygon2D.new()
	center_polygon.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(8, 4),
		Vector2(3, 4),
		Vector2(3, 12),
		Vector2(-3, 12),
		Vector2(-3, 4),
		Vector2(-8, 4)
	])
	center_polygon.color = CALYX_CYAN
	center_polygon.z_index = 6
	add_child(center_polygon)

	# Progress ring (hidden until extracting)
	progress_ring = Line2D.new()
	progress_ring.width = 4.0
	progress_ring.default_color = Color("#00ff00")
	progress_ring.z_index = 7
	progress_ring.visible = false
	add_child(progress_ring)

	# Glow light
	glow_light = PointLight2D.new()
	glow_light.color = CALYX_CYAN
	glow_light.energy = 0.6
	glow_light.texture_scale = 1.5
	_setup_light_texture(glow_light)
	add_child(glow_light)

func _create_collision() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0
	shape.shape = circle
	add_child(shape)

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

func _process(delta: float) -> void:
	# Pulse animation
	pulse_time += delta * 2.0
	var pulse := 1.0 + sin(pulse_time) * 0.1
	outer_ring.scale = Vector2(pulse, pulse)
	inner_ring.rotation += delta * 0.5
	glow_light.energy = 0.6 + sin(pulse_time) * 0.2

	# Handle extraction
	if is_extracting and player_in_range:
		extraction_progress += delta / extraction_time
		_update_progress_ring()

		if extraction_progress >= 1.0:
			_complete_extraction()
	elif is_extracting and not player_in_range:
		# Abort extraction if player leaves
		is_extracting = false
		extraction_progress = 0.0
		progress_ring.visible = false

func _update_progress_ring() -> void:
	progress_ring.visible = true
	var points := PackedVector2Array()
	var segments := int(extraction_progress * 32)

	for i in range(segments + 1):
		var t := float(i) / 32.0
		var angle := t * TAU - PI / 2
		points.append(Vector2(cos(angle), sin(angle)) * 32)

	progress_ring.points = points

func _complete_extraction() -> void:
	is_extracting = false
	extraction_progress = 0.0
	progress_ring.visible = false

	# Trigger extraction complete
	GameManager.complete_extraction()

	# Visual effect
	var tween := create_tween()
	tween.parallel().tween_property(outer_ring, "scale", Vector2(2, 2), 0.3)
	tween.parallel().tween_property(outer_ring, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(inner_ring, "scale", Vector2(2, 2), 0.3)
	tween.parallel().tween_property(glow_light, "energy", 3.0, 0.2)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		is_extracting = true
		extraction_started.emit(self)
		_show_extraction_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _show_extraction_prompt() -> void:
	# Flash the rings
	var tween := create_tween()
	tween.tween_property(outer_ring, "default_color", Color("#00ff00"), 0.2)
	tween.tween_property(outer_ring, "default_color", CALYX_CYAN, 0.2)
