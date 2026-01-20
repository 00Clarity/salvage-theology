class_name TheologyDoor
extends Area2D

enum DoorState { LOCKED, PAID, OPEN }
enum PaymentType { ITEM, HEALTH, MEMORY }

signal door_opened(door: TheologyDoor)
signal payment_requested(door: TheologyDoor)
signal player_entered_threshold(door: TheologyDoor)
signal player_exited_threshold(door: TheologyDoor)

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")

@export var direction: RoomData.DoorDirection
@export var accepted_payments: Array[PaymentType] = [
	PaymentType.ITEM,
	PaymentType.HEALTH,
	PaymentType.MEMORY
]

var state: DoorState = DoorState.LOCKED
var door_id: String = ""
var room_id: String = ""

# Visual components
var frame_line: Line2D
var threshold_area: Area2D
var glow_light: PointLight2D
var lock_indicator: Polygon2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Generate unique ID
	door_id = str(randi())

func setup(dir: RoomData.DoorDirection, pos: Vector2, size: Vector2) -> void:
	direction = dir
	position = pos

	_create_collision(size)
	_create_visuals(size)
	_create_threshold_zone(size)
	_update_visual_state()

func _create_collision(size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	add_child(shape)

func _create_visuals(size: Vector2) -> void:
	# Door frame
	frame_line = Line2D.new()
	frame_line.points = PackedVector2Array([
		Vector2(-size.x / 2, -size.y / 2),
		Vector2(size.x / 2, -size.y / 2),
		Vector2(size.x / 2, size.y / 2),
		Vector2(-size.x / 2, size.y / 2),
		Vector2(-size.x / 2, -size.y / 2)
	])
	frame_line.width = 3.0
	frame_line.default_color = CALYX_CYAN
	frame_line.z_index = 1
	add_child(frame_line)

	# Lock indicator (small diamond in center)
	lock_indicator = Polygon2D.new()
	lock_indicator.polygon = PackedVector2Array([
		Vector2(0, -8),
		Vector2(8, 0),
		Vector2(0, 8),
		Vector2(-8, 0)
	])
	lock_indicator.color = Color("#ff6600")  # Orange for locked
	lock_indicator.z_index = 2
	add_child(lock_indicator)

	# Glow light
	glow_light = PointLight2D.new()
	glow_light.color = CALYX_CYAN
	glow_light.energy = 0.5
	glow_light.texture_scale = 0.6
	_setup_light_texture(glow_light)
	add_child(glow_light)

func _create_threshold_zone(size: Vector2) -> void:
	# Threshold is the area where player is protected
	threshold_area = Area2D.new()
	threshold_area.set_meta("is_threshold", true)
	threshold_area.add_to_group("threshold")

	var threshold_shape := CollisionShape2D.new()
	var threshold_rect := RectangleShape2D.new()
	# Threshold is slightly smaller than door
	threshold_rect.size = size * 0.8
	threshold_shape.shape = threshold_rect
	threshold_area.add_child(threshold_shape)

	threshold_area.body_entered.connect(_on_threshold_entered)
	threshold_area.body_exited.connect(_on_threshold_exited)

	add_child(threshold_area)

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

func _update_visual_state() -> void:
	match state:
		DoorState.LOCKED:
			frame_line.default_color = Color(CALYX_CYAN, 0.6)
			lock_indicator.visible = true
			lock_indicator.color = Color("#ff6600")
			glow_light.energy = 0.3
		DoorState.PAID:
			frame_line.default_color = CALYX_CYAN
			lock_indicator.visible = true
			lock_indicator.color = CALYX_TEAL
			glow_light.energy = 0.6
		DoorState.OPEN:
			frame_line.default_color = CALYX_CYAN
			lock_indicator.visible = false
			glow_light.energy = 0.8

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match state:
		DoorState.LOCKED:
			payment_requested.emit(self)
		DoorState.PAID, DoorState.OPEN:
			_open_door()
			door_opened.emit(self)

func _on_body_exited(_body: Node2D) -> void:
	pass

func _on_threshold_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered_threshold.emit(self)

func _on_threshold_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_exited_threshold.emit(self)

func request_payment() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var player = _get_player()
	if not player:
		return options

	if PaymentType.ITEM in accepted_payments:
		if player.has_items():
			options.append({
				"type": PaymentType.ITEM,
				"label": "Sacrifice Item",
				"description": "Offer an item to pass"
			})

	if PaymentType.HEALTH in accepted_payments:
		if player.health > player.max_health * 0.15:
			options.append({
				"type": PaymentType.HEALTH,
				"label": "Sacrifice Health",
				"description": "Lose 10% max health"
			})

	if PaymentType.MEMORY in accepted_payments:
		if player.has_memories():
			options.append({
				"type": PaymentType.MEMORY,
				"label": "Sacrifice Memory",
				"description": "Forget something you learned"
			})

	return options

func execute_payment(payment_type: PaymentType) -> bool:
	var player = _get_player()
	if not player:
		return false

	var success := false

	match payment_type:
		PaymentType.ITEM:
			if player.has_items():
				player.sacrifice_item()
				success = true
		PaymentType.HEALTH:
			if player.health > player.max_health * 0.15:
				player.sacrifice_health(player.max_health * 0.1)
				success = true
		PaymentType.MEMORY:
			if player.has_memories():
				player.sacrifice_memory()
				success = true

	if success:
		state = DoorState.PAID
		_update_visual_state()
		_play_payment_effect(payment_type)

	return success

func _open_door() -> void:
	if state == DoorState.OPEN:
		return

	state = DoorState.OPEN
	_update_visual_state()
	_play_open_effect()

	# Permanence: Save door state (doors never close)
	if GameManager:
		GameManager.set_door_state(room_id, door_id, DoorState.OPEN)

func _play_payment_effect(payment_type: PaymentType) -> void:
	var effect_color: Color
	match payment_type:
		PaymentType.ITEM:
			effect_color = Color("#ffd700")  # Gold
		PaymentType.HEALTH:
			effect_color = Color("#ff0000")  # Red
		PaymentType.MEMORY:
			effect_color = Color("#e6e6fa")  # Lavender

	# Flash the door frame
	var tween := create_tween()
	tween.tween_property(frame_line, "default_color", effect_color, 0.15)
	tween.tween_property(frame_line, "default_color", CALYX_CYAN, 0.3)

func _play_open_effect() -> void:
	# Pulse the glow
	var tween := create_tween()
	tween.tween_property(glow_light, "energy", 1.5, 0.2)
	tween.tween_property(glow_light, "energy", 0.8, 0.3)

func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")

func is_open() -> bool:
	return state == DoorState.OPEN

func is_locked() -> bool:
	return state == DoorState.LOCKED
