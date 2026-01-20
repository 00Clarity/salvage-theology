extends CanvasLayer

## HUD: Heads-up display for player stats
## Shows oxygen, health, depth, inventory, material, and corruption

const NORMAL_COLOR := Color(0, 1, 1, 0.9)
const WARNING_COLOR := Color(1, 0.5, 0, 0.9)
const CRITICAL_COLOR := Color(1, 0, 0, 0.9)
const HEALTH_COLOR := Color(1, 0.3, 0.3, 0.9)
const MATERIAL_COLOR := Color(1, 0.84, 0, 0.9)
const CORRUPTION_COLOR := Color(0.5, 1, 1, 0.9)

@onready var oxygen_bar: ProgressBar = $OxygenContainer/OxygenBar
@onready var oxygen_label: Label = $OxygenContainer/OxygenLabel
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var health_label: Label = $HealthContainer/HealthLabel
@onready var depth_label: Label = $DepthLabel
@onready var inventory_label: Label = $InventoryLabel
@onready var threshold_indicator: Label = $ThresholdIndicator
@onready var death_panel: Panel = $DeathPanel
@onready var restart_button: Button = $DeathPanel/VBoxContainer/RestartButton

var material_label: Label
var corruption_bar: ProgressBar

var warning_pulse_time: float = 0.0
var is_warning: bool = false
var player_ref: Node2D

func _ready() -> void:
	if death_panel:
		death_panel.visible = false
	else:
		push_warning("[HUD] _ready: DeathPanel not found")

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		push_warning("[HUD] _ready: RestartButton not found")

	_create_material_display()
	_create_corruption_display()

	# Validate required UI elements
	if not oxygen_bar:
		push_warning("[HUD] _ready: OxygenBar not found")
	if not oxygen_label:
		push_warning("[HUD] _ready: OxygenLabel not found")
	if not health_bar:
		push_warning("[HUD] _ready: HealthBar not found")
	if not health_label:
		push_warning("[HUD] _ready: HealthLabel not found")

func _create_material_display() -> void:
	material_label = Label.new()
	material_label.text = "MATERIAL: 0"
	material_label.position = Vector2(20, 200)
	material_label.add_theme_color_override("font_color", MATERIAL_COLOR)
	material_label.add_theme_font_size_override("font_size", 16)
	add_child(material_label)

func _create_corruption_display() -> void:
	var container := VBoxContainer.new()
	container.position = Vector2(20, 230)

	var label := Label.new()
	label.text = "CORRUPTION"
	label.add_theme_color_override("font_color", Color(CORRUPTION_COLOR, 0.8))
	label.add_theme_font_size_override("font_size", 12)
	container.add_child(label)

	corruption_bar = ProgressBar.new()
	corruption_bar.custom_minimum_size = Vector2(120, 8)
	corruption_bar.max_value = 100.0
	corruption_bar.value = 0.0
	corruption_bar.show_percentage = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.1, 0.8)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	corruption_bar.add_theme_stylebox_override("background", style)

	container.add_child(corruption_bar)
	add_child(container)

func _process(delta: float) -> void:
	if is_warning:
		warning_pulse_time += delta * 4.0
		var pulse := 0.7 + sin(warning_pulse_time) * 0.3
		oxygen_bar.modulate.a = pulse

	_update_player_stats()

func _update_player_stats() -> void:
	if not player_ref or not is_instance_valid(player_ref):
		var tree := get_tree()
		if not tree:
			return
		player_ref = tree.get_first_node_in_group("player")
		if not player_ref:
			return

	# Validate player has required properties
	if not "health" in player_ref or not "max_health" in player_ref:
		push_warning("[HUD] _update_player_stats: Player missing health properties")
		return

	# Update health
	var max_hp: float = player_ref.max_health
	if max_hp <= 0:
		push_warning("[HUD] _update_player_stats: max_health is non-positive (%.2f)" % max_hp)
		max_hp = 1.0  # Prevent division by zero

	var health_percent: float = player_ref.health / max_hp
	if health_bar:
		health_bar.max_value = player_ref.max_health
		health_bar.value = player_ref.health

		if health_percent <= 0.25:
			health_bar.modulate = CRITICAL_COLOR
		elif health_percent <= 0.5:
			health_bar.modulate = WARNING_COLOR
		else:
			health_bar.modulate = HEALTH_COLOR

	if health_label:
		health_label.text = "HP: %d%%" % int(health_percent * 100)

	# Update inventory
	if inventory_label and "inventory" in player_ref:
		var item_count: int = player_ref.inventory.size() if player_ref.inventory else 0
		inventory_label.text = "ITEMS: %d" % item_count

	# Update threshold indicator
	if threshold_indicator and "in_threshold" in player_ref:
		threshold_indicator.visible = player_ref.in_threshold

	# Update material display
	if material_label and "divine_material_value" in player_ref:
		material_label.text = "MATERIAL: %d" % player_ref.divine_material_value

	# Update corruption display
	if corruption_bar and "corruption_level" in player_ref:
		corruption_bar.value = player_ref.corruption_level * 100.0
		if player_ref.corruption_level > 0.5:
			corruption_bar.modulate = Color(1, 0.5, 1, 1)  # Purple warning
		else:
			corruption_bar.modulate = CORRUPTION_COLOR

func _on_resource_changed(resource_name: String, value: float, max_value: float) -> void:
	if resource_name == "oxygen":
		update_oxygen_display(value, max_value)

func update_oxygen_display(value: float, max_value: float) -> void:
	if max_value <= 0:
		push_warning("[HUD] update_oxygen_display: max_value is non-positive (%.2f)" % max_value)
		max_value = 1.0  # Prevent division by zero

	if oxygen_bar:
		oxygen_bar.max_value = max_value
		oxygen_bar.value = value

	var percent := value / max_value

	if oxygen_label:
		oxygen_label.text = "O2: %d%%" % int(percent * 100)

	if oxygen_bar:
		if percent <= 0.15:
			oxygen_bar.modulate = CRITICAL_COLOR
			is_warning = true
		elif percent <= 0.25:
			oxygen_bar.modulate = WARNING_COLOR
			is_warning = true
		else:
			oxygen_bar.modulate = NORMAL_COLOR
			is_warning = false
			oxygen_bar.modulate.a = 1.0

func update_depth(depth: int) -> void:
	if depth < 0:
		push_warning("[HUD] update_depth: depth is negative (%d)" % depth)
		depth = 0
	if depth_label:
		depth_label.text = "DEPTH: %d" % depth

func show_death_screen() -> void:
	if death_panel:
		death_panel.visible = true
	else:
		push_warning("[HUD] show_death_screen: DeathPanel not found")

func hide_death_screen() -> void:
	if death_panel:
		death_panel.visible = false
	else:
		push_warning("[HUD] hide_death_screen: DeathPanel not found")

func _on_restart_pressed() -> void:
	if GameManager:
		GameManager.restart_game()
	else:
		push_error("[HUD] _on_restart_pressed: GameManager not available")
