class_name DivineMaterial
extends Area2D

signal collected(material: DivineMaterial)

enum Grade { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const GRADE_COLORS := {
	Grade.COMMON: Color("#80ffff"),
	Grade.UNCOMMON: Color("#40ff40"),
	Grade.RARE: Color("#4080ff"),
	Grade.EPIC: Color("#ff40ff"),
	Grade.LEGENDARY: Color("#ffd700")
}

const GRADE_VALUES := {
	Grade.COMMON: 10,
	Grade.UNCOMMON: 25,
	Grade.RARE: 50,
	Grade.EPIC: 100,
	Grade.LEGENDARY: 250
}

@export var grade: Grade = Grade.COMMON
@export var material_name: String = "Divine Fragment"

var value: int = 10
var pulse_time: float = 0.0

var body_polygon: Polygon2D
var glow_light: PointLight2D
var outer_ring: Line2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	value = GRADE_VALUES[grade]
	_create_visual()
	_create_collision()

func _create_visual() -> void:
	var color := GRADE_COLORS[grade]

	# Main body - hexagonal crystal
	body_polygon = Polygon2D.new()
	var points := PackedVector2Array()
	var size := 8.0 + grade * 2  # Larger for rarer materials
	for i in range(6):
		var angle := i * TAU / 6 - PI / 2
		points.append(Vector2(cos(angle), sin(angle)) * size)
	body_polygon.polygon = points
	body_polygon.color = color
	body_polygon.z_index = 5
	add_child(body_polygon)

	# Inner highlight
	var inner := Polygon2D.new()
	var inner_points := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6 - PI / 2
		inner_points.append(Vector2(cos(angle), sin(angle)) * (size * 0.5))
	inner.polygon = inner_points
	inner.color = Color(color, 0.5).lightened(0.3)
	body_polygon.add_child(inner)

	# Outer ring
	outer_ring = Line2D.new()
	var ring_points := PackedVector2Array()
	for i in range(7):
		var angle := i * TAU / 6 - PI / 2
		ring_points.append(Vector2(cos(angle), sin(angle)) * (size + 4))
	outer_ring.points = ring_points
	outer_ring.width = 2.0
	outer_ring.default_color = Color(color, 0.6)
	outer_ring.z_index = 4
	add_child(outer_ring)

	# Glow
	glow_light = PointLight2D.new()
	glow_light.color = color
	glow_light.energy = 0.4 + grade * 0.15
	glow_light.texture_scale = 0.3 + grade * 0.1
	_setup_light_texture(glow_light)
	add_child(glow_light)

func _create_collision() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0 + grade * 2
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
	# Gentle pulse
	pulse_time += delta * 2.0
	var pulse := 1.0 + sin(pulse_time) * 0.1
	body_polygon.scale = Vector2(pulse, pulse)
	glow_light.energy = (0.4 + grade * 0.15) * pulse

	# Slow rotation
	outer_ring.rotation += delta * 0.5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("collect_material"):
			body.collect_material(self)
		collected.emit(self)
		_play_pickup_effect()
		queue_free()

func _play_pickup_effect() -> void:
	# Expand and fade (handled before queue_free)
	var tween := create_tween()
	tween.parallel().tween_property(body_polygon, "scale", Vector2(2, 2), 0.2)
	tween.parallel().tween_property(body_polygon, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(glow_light, "energy", 2.0, 0.1)
	tween.tween_property(glow_light, "energy", 0.0, 0.1)

static func create_random(depth: int) -> DivineMaterial:
	var material := DivineMaterial.new()

	# Grade distribution based on depth
	var roll := randf()
	if depth >= 9:
		if roll < 0.05:
			material.grade = Grade.LEGENDARY
		elif roll < 0.2:
			material.grade = Grade.EPIC
		elif roll < 0.45:
			material.grade = Grade.RARE
		elif roll < 0.75:
			material.grade = Grade.UNCOMMON
		else:
			material.grade = Grade.COMMON
	elif depth >= 6:
		if roll < 0.1:
			material.grade = Grade.EPIC
		elif roll < 0.3:
			material.grade = Grade.RARE
		elif roll < 0.6:
			material.grade = Grade.UNCOMMON
		else:
			material.grade = Grade.COMMON
	elif depth >= 3:
		if roll < 0.15:
			material.grade = Grade.RARE
		elif roll < 0.4:
			material.grade = Grade.UNCOMMON
		else:
			material.grade = Grade.COMMON
	else:
		if roll < 0.2:
			material.grade = Grade.UNCOMMON
		else:
			material.grade = Grade.COMMON

	material.value = GRADE_VALUES[material.grade]
	return material
