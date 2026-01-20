class_name SalvagerBody
extends Node2D

# Colors from Calyx palette - enhanced with depth
const BASE_COLOR = Color(0.04, 0.06, 0.1)       # Dark suit (#0a0f1a)
const BASE_HIGHLIGHT = Color(0.08, 0.12, 0.2)   # Suit highlight
const BASE_SHADOW = Color(0.02, 0.03, 0.05)     # Suit shadow
const ACCENT_COLOR = Color(0, 1, 1)             # Cyan
const ACCENT_BRIGHT = Color(0.5, 1, 1)          # Bright cyan
const VISOR_COLOR = Color(0, 1, 1, 0.95)        # Bright visor
const VISOR_CORE = Color(1, 1, 1, 0.9)          # White hot center

# Body part references for animation
var head: Polygon2D
var visor: Polygon2D
var visor_inner: Polygon2D
var torso: Polygon2D
var visor_light: PointLight2D
var body_light: PointLight2D
var energy_field: Line2D

# Breathing animation
var breath_time: float = 0.0
var visor_pulse_time: float = 0.0
var energy_time: float = 0.0

func _ready() -> void:
	create_body()
	create_lights()

func _process(delta: float) -> void:
	animate_idle(delta)

func create_body() -> void:
	# ENERGY FIELD (subtle aura)
	energy_field = Line2D.new()
	energy_field.name = "EnergyField"
	energy_field.width = 2.0
	energy_field.default_color = Color(ACCENT_COLOR, 0.15)
	energy_field.z_index = -1
	_create_energy_field_points()
	add_child(energy_field)

	# HEAD (helmet) - with shadow layer
	var head_shadow := Polygon2D.new()
	head_shadow.polygon = PackedVector2Array([
		Vector2(-11, -59), Vector2(11, -59),
		Vector2(13, -47), Vector2(13, -43),
		Vector2(-13, -43), Vector2(-13, -47),
	])
	head_shadow.color = BASE_SHADOW
	add_child(head_shadow)

	head = Polygon2D.new()
	head.name = "Head"
	head.polygon = PackedVector2Array([
		Vector2(-10, -60), Vector2(10, -60),
		Vector2(12, -48), Vector2(12, -44),
		Vector2(-12, -44), Vector2(-12, -48),
	])
	head.color = BASE_COLOR
	add_child(head)

	# Helmet ridge detail
	var helmet_ridge := Line2D.new()
	helmet_ridge.points = PackedVector2Array([
		Vector2(-9, -59), Vector2(0, -62), Vector2(9, -59)
	])
	helmet_ridge.width = 2.0
	helmet_ridge.default_color = BASE_HIGHLIGHT
	head.add_child(helmet_ridge)

	# VISOR (glowing slit) - with layered glow
	var visor_glow := Polygon2D.new()
	visor_glow.name = "VisorGlow"
	visor_glow.polygon = PackedVector2Array([
		Vector2(-10, -56), Vector2(10, -56),
		Vector2(10, -48), Vector2(-10, -48),
	])
	visor_glow.color = Color(ACCENT_COLOR, 0.3)
	head.add_child(visor_glow)

	visor = Polygon2D.new()
	visor.name = "Visor"
	visor.polygon = PackedVector2Array([
		Vector2(-8, -54), Vector2(8, -54),
		Vector2(8, -50), Vector2(-8, -50),
	])
	visor.color = VISOR_COLOR
	head.add_child(visor)

	# Visor inner core (white hot center)
	visor_inner = Polygon2D.new()
	visor_inner.name = "VisorInner"
	visor_inner.polygon = PackedVector2Array([
		Vector2(-5, -53), Vector2(5, -53),
		Vector2(5, -51), Vector2(-5, -51),
	])
	visor_inner.color = VISOR_CORE
	visor.add_child(visor_inner)

	# Visor reflection lines
	var visor_line := Line2D.new()
	visor_line.points = PackedVector2Array([Vector2(-6, -52.5), Vector2(6, -52.5)])
	visor_line.width = 0.5
	visor_line.default_color = Color.WHITE
	visor.add_child(visor_line)

	# TORSO shadow layer
	var torso_shadow := Polygon2D.new()
	torso_shadow.polygon = PackedVector2Array([
		Vector2(-12, -43), Vector2(12, -43),
		Vector2(10, -19), Vector2(-10, -19),
	])
	torso_shadow.color = BASE_SHADOW
	add_child(torso_shadow)

	# TORSO
	torso = Polygon2D.new()
	torso.name = "Torso"
	torso.polygon = PackedVector2Array([
		Vector2(-11, -44), Vector2(11, -44),
		Vector2(9, -20), Vector2(-9, -20),
	])
	torso.color = BASE_COLOR
	add_child(torso)

	# Chest plate overlay
	var chest_plate := Polygon2D.new()
	chest_plate.polygon = PackedVector2Array([
		Vector2(-7, -42), Vector2(7, -42),
		Vector2(5, -28), Vector2(-5, -28),
	])
	chest_plate.color = BASE_HIGHLIGHT
	torso.add_child(chest_plate)

	# TORSO ACCENT LINE (center seam) - enhanced with glow
	var torso_line_glow := Line2D.new()
	torso_line_glow.points = PackedVector2Array([Vector2(0, -42), Vector2(0, -22)])
	torso_line_glow.width = 4.0
	torso_line_glow.default_color = Color(ACCENT_COLOR, 0.3)
	torso.add_child(torso_line_glow)

	var torso_line := Line2D.new()
	torso_line.name = "TorsoAccent"
	torso_line.points = PackedVector2Array([Vector2(0, -42), Vector2(0, -22)])
	torso_line.width = 1.5
	torso_line.default_color = ACCENT_COLOR
	torso.add_child(torso_line)

	# Circular chest emblem
	var emblem := Line2D.new()
	var emblem_points := PackedVector2Array()
	for i in range(13):
		var angle := float(i) / 12.0 * TAU
		emblem_points.append(Vector2(cos(angle), sin(angle)) * 4 + Vector2(0, -35))
	emblem.points = emblem_points
	emblem.width = 1.5
	emblem.default_color = ACCENT_BRIGHT
	torso.add_child(emblem)

	# SHOULDER ACCENTS - enhanced with glow
	var shoulder_l_glow := Line2D.new()
	shoulder_l_glow.points = PackedVector2Array([Vector2(-11, -43), Vector2(-7, -38)])
	shoulder_l_glow.width = 3.0
	shoulder_l_glow.default_color = Color(ACCENT_COLOR, 0.3)
	torso.add_child(shoulder_l_glow)

	var shoulder_l := Line2D.new()
	shoulder_l.points = PackedVector2Array([Vector2(-11, -43), Vector2(-7, -38)])
	shoulder_l.width = 1.5
	shoulder_l.default_color = ACCENT_COLOR
	torso.add_child(shoulder_l)

	var shoulder_r_glow := Line2D.new()
	shoulder_r_glow.points = PackedVector2Array([Vector2(11, -43), Vector2(7, -38)])
	shoulder_r_glow.width = 3.0
	shoulder_r_glow.default_color = Color(ACCENT_COLOR, 0.3)
	torso.add_child(shoulder_r_glow)

	var shoulder_r := Line2D.new()
	shoulder_r.points = PackedVector2Array([Vector2(11, -43), Vector2(7, -38)])
	shoulder_r.width = 1.5
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
	# Visor glow light - main
	visor_light = PointLight2D.new()
	visor_light.name = "VisorLight"
	visor_light.position = Vector2(0, -52)
	visor_light.color = ACCENT_COLOR
	visor_light.energy = 1.0
	visor_light.texture_scale = 0.5
	_setup_light_texture(visor_light)
	add_child(visor_light)

	# Body ambient light
	body_light = PointLight2D.new()
	body_light.name = "BodyLight"
	body_light.position = Vector2(0, -30)
	body_light.color = ACCENT_COLOR
	body_light.energy = 0.3
	body_light.texture_scale = 1.0
	_setup_light_texture(body_light)
	add_child(body_light)

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

func _create_energy_field_points() -> void:
	var points := PackedVector2Array()
	# Create a subtle energy outline around the character
	points.append(Vector2(-14, -58))
	points.append(Vector2(-16, -45))
	points.append(Vector2(-18, -30))
	points.append(Vector2(-16, -15))
	points.append(Vector2(-10, 0))
	points.append(Vector2(-8, 20))
	points.append(Vector2(-6, 26))
	points.append(Vector2(6, 26))
	points.append(Vector2(8, 20))
	points.append(Vector2(10, 0))
	points.append(Vector2(16, -15))
	points.append(Vector2(18, -30))
	points.append(Vector2(16, -45))
	points.append(Vector2(14, -58))
	energy_field.points = points

func animate_idle(delta: float) -> void:
	# Subtle breathing animation
	breath_time += delta * 1.5
	var breath_scale := 1.0 + sin(breath_time) * 0.015
	if torso:
		torso.scale.y = breath_scale

	# Visor pulse - more dynamic
	visor_pulse_time += delta * 3.0
	var pulse := 0.8 + sin(visor_pulse_time) * 0.2
	if visor_light:
		visor_light.energy = pulse
	if visor_inner:
		visor_inner.modulate.a = 0.7 + sin(visor_pulse_time * 1.5) * 0.3

	# Energy field animation
	energy_time += delta * 2.0
	if energy_field:
		var wave := 0.1 + sin(energy_time) * 0.05
		energy_field.default_color = Color(ACCENT_COLOR, wave)
		# Subtle scale pulse
		energy_field.scale = Vector2(1.0 + sin(energy_time * 0.5) * 0.02, 1.0)

	# Body light subtle pulse
	if body_light:
		body_light.energy = 0.25 + sin(breath_time * 0.7) * 0.1
