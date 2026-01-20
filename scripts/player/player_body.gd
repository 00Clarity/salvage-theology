class_name SalvagerBody
extends Node2D

# Colors from Calyx palette
const BASE_COLOR = Color(0.04, 0.06, 0.1)       # Dark suit (#0a0f1a)
const ACCENT_COLOR = Color(0, 1, 1)             # Cyan
const VISOR_COLOR = Color(0, 1, 1, 0.95)        # Bright visor

# Body part references for animation
var head: Polygon2D
var visor: Polygon2D
var torso: Polygon2D
var visor_light: PointLight2D

# Breathing animation
var breath_time: float = 0.0
var visor_pulse_time: float = 0.0

func _ready() -> void:
	create_body()
	create_lights()

func _process(delta: float) -> void:
	animate_idle(delta)

func create_body() -> void:
	# HEAD (helmet)
	head = Polygon2D.new()
	head.name = "Head"
	head.polygon = PackedVector2Array([
		Vector2(-10, -60), Vector2(10, -60),   # Top
		Vector2(12, -48), Vector2(12, -44),    # Right side
		Vector2(-12, -44), Vector2(-12, -48),  # Left side
	])
	head.color = BASE_COLOR
	add_child(head)

	# VISOR (glowing slit)
	visor = Polygon2D.new()
	visor.name = "Visor"
	visor.polygon = PackedVector2Array([
		Vector2(-8, -54), Vector2(8, -54),
		Vector2(8, -50), Vector2(-8, -50),
	])
	visor.color = VISOR_COLOR
	head.add_child(visor)

	# TORSO
	torso = Polygon2D.new()
	torso.name = "Torso"
	torso.polygon = PackedVector2Array([
		Vector2(-11, -44), Vector2(11, -44),   # Shoulders
		Vector2(9, -20), Vector2(-9, -20),     # Waist
	])
	torso.color = BASE_COLOR
	add_child(torso)

	# TORSO ACCENT LINE (center seam)
	var torso_line = Line2D.new()
	torso_line.name = "TorsoAccent"
	torso_line.points = PackedVector2Array([
		Vector2(0, -42), Vector2(0, -22)
	])
	torso_line.width = 1.5
	torso_line.default_color = ACCENT_COLOR
	torso.add_child(torso_line)

	# SHOULDER ACCENTS
	var shoulder_l = Line2D.new()
	shoulder_l.points = PackedVector2Array([Vector2(-11, -43), Vector2(-8, -40)])
	shoulder_l.width = 1.0
	shoulder_l.default_color = ACCENT_COLOR
	torso.add_child(shoulder_l)

	var shoulder_r = Line2D.new()
	shoulder_r.points = PackedVector2Array([Vector2(11, -43), Vector2(8, -40)])
	shoulder_r.width = 1.0
	shoulder_r.default_color = ACCENT_COLOR
	torso.add_child(shoulder_r)

	# LEFT ARM (upper)
	var arm_l_upper = Polygon2D.new()
	arm_l_upper.name = "ArmLeftUpper"
	arm_l_upper.polygon = PackedVector2Array([
		Vector2(-14, -42), Vector2(-11, -42),
		Vector2(-12, -30), Vector2(-16, -30),
	])
	arm_l_upper.color = BASE_COLOR
	add_child(arm_l_upper)

	# LEFT ARM (lower)
	var arm_l_lower = Polygon2D.new()
	arm_l_lower.name = "ArmLeftLower"
	arm_l_lower.polygon = PackedVector2Array([
		Vector2(-16, -30), Vector2(-12, -30),
		Vector2(-11, -16), Vector2(-15, -16),
	])
	arm_l_lower.color = BASE_COLOR
	add_child(arm_l_lower)

	# LEFT ARM ACCENT
	var arm_l_accent = Line2D.new()
	arm_l_accent.points = PackedVector2Array([Vector2(-14, -30), Vector2(-13, -18)])
	arm_l_accent.width = 1.0
	arm_l_accent.default_color = ACCENT_COLOR
	arm_l_lower.add_child(arm_l_accent)

	# RIGHT ARM (upper)
	var arm_r_upper = Polygon2D.new()
	arm_r_upper.name = "ArmRightUpper"
	arm_r_upper.polygon = PackedVector2Array([
		Vector2(11, -42), Vector2(14, -42),
		Vector2(16, -30), Vector2(12, -30),
	])
	arm_r_upper.color = BASE_COLOR
	add_child(arm_r_upper)

	# RIGHT ARM (lower)
	var arm_r_lower = Polygon2D.new()
	arm_r_lower.name = "ArmRightLower"
	arm_r_lower.polygon = PackedVector2Array([
		Vector2(12, -30), Vector2(16, -30),
		Vector2(15, -16), Vector2(11, -16),
	])
	arm_r_lower.color = BASE_COLOR
	add_child(arm_r_lower)

	# RIGHT ARM ACCENT
	var arm_r_accent = Line2D.new()
	arm_r_accent.points = PackedVector2Array([Vector2(14, -30), Vector2(13, -18)])
	arm_r_accent.width = 1.0
	arm_r_accent.default_color = ACCENT_COLOR
	arm_r_lower.add_child(arm_r_accent)

	# HIPS
	var hips = Polygon2D.new()
	hips.name = "Hips"
	hips.polygon = PackedVector2Array([
		Vector2(-9, -20), Vector2(9, -20),
		Vector2(8, -14), Vector2(-8, -14),
	])
	hips.color = BASE_COLOR
	add_child(hips)

	# HIP ACCENT
	var hip_accent = Line2D.new()
	hip_accent.points = PackedVector2Array([Vector2(-7, -17), Vector2(7, -17)])
	hip_accent.width = 1.0
	hip_accent.default_color = ACCENT_COLOR
	hips.add_child(hip_accent)

	# LEFT LEG (upper)
	var leg_l_upper = Polygon2D.new()
	leg_l_upper.name = "LegLeftUpper"
	leg_l_upper.polygon = PackedVector2Array([
		Vector2(-8, -14), Vector2(-2, -14),
		Vector2(-3, 4), Vector2(-7, 4),
	])
	leg_l_upper.color = BASE_COLOR
	add_child(leg_l_upper)

	# LEFT LEG (lower)
	var leg_l_lower = Polygon2D.new()
	leg_l_lower.name = "LegLeftLower"
	leg_l_lower.polygon = PackedVector2Array([
		Vector2(-7, 4), Vector2(-3, 4),
		Vector2(-2, 24), Vector2(-6, 24),
	])
	leg_l_lower.color = BASE_COLOR
	add_child(leg_l_lower)

	# LEFT LEG ACCENT
	var leg_l_accent = Line2D.new()
	leg_l_accent.points = PackedVector2Array([Vector2(-5, 6), Vector2(-4, 22)])
	leg_l_accent.width = 1.0
	leg_l_accent.default_color = ACCENT_COLOR
	leg_l_lower.add_child(leg_l_accent)

	# RIGHT LEG (upper)
	var leg_r_upper = Polygon2D.new()
	leg_r_upper.name = "LegRightUpper"
	leg_r_upper.polygon = PackedVector2Array([
		Vector2(2, -14), Vector2(8, -14),
		Vector2(7, 4), Vector2(3, 4),
	])
	leg_r_upper.color = BASE_COLOR
	add_child(leg_r_upper)

	# RIGHT LEG (lower)
	var leg_r_lower = Polygon2D.new()
	leg_r_lower.name = "LegRightLower"
	leg_r_lower.polygon = PackedVector2Array([
		Vector2(3, 4), Vector2(7, 4),
		Vector2(6, 24), Vector2(2, 24),
	])
	leg_r_lower.color = BASE_COLOR
	add_child(leg_r_lower)

	# RIGHT LEG ACCENT
	var leg_r_accent = Line2D.new()
	leg_r_accent.points = PackedVector2Array([Vector2(5, 6), Vector2(4, 22)])
	leg_r_accent.width = 1.0
	leg_r_accent.default_color = ACCENT_COLOR
	leg_r_lower.add_child(leg_r_accent)

func create_lights() -> void:
	# Visor glow light
	visor_light = PointLight2D.new()
	visor_light.name = "VisorLight"
	visor_light.position = Vector2(0, -52)
	visor_light.color = ACCENT_COLOR
	visor_light.energy = 0.8
	visor_light.texture = load("res://assets/light_gradient.tres")
	visor_light.texture_scale = 0.4
	add_child(visor_light)

func animate_idle(delta: float) -> void:
	# Subtle breathing animation
	breath_time += delta * 1.5
	var breath_scale = 1.0 + sin(breath_time) * 0.015
	if torso:
		torso.scale.y = breath_scale

	# Visor pulse
	visor_pulse_time += delta * 2.0
	var pulse = 0.7 + sin(visor_pulse_time) * 0.15
	if visor_light:
		visor_light.energy = pulse
