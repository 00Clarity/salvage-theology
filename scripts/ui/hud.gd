extends CanvasLayer

const NORMAL_COLOR := Color(0, 1, 1, 0.9)
const WARNING_COLOR := Color(1, 0.5, 0, 0.9)
const CRITICAL_COLOR := Color(1, 0, 0, 0.9)
const HEALTH_COLOR := Color(1, 0.3, 0.3, 0.9)

@onready var oxygen_bar: ProgressBar = $OxygenContainer/OxygenBar
@onready var oxygen_label: Label = $OxygenContainer/OxygenLabel
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var health_label: Label = $HealthContainer/HealthLabel
@onready var depth_label: Label = $DepthLabel
@onready var inventory_label: Label = $InventoryLabel
@onready var threshold_indicator: Label = $ThresholdIndicator
@onready var death_panel: Panel = $DeathPanel
@onready var restart_button: Button = $DeathPanel/VBoxContainer/RestartButton

var warning_pulse_time: float = 0.0
var is_warning: bool = false
var player_ref: Node2D

func _ready() -> void:
	death_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func _process(delta: float) -> void:
	if is_warning:
		warning_pulse_time += delta * 4.0
		var pulse := 0.7 + sin(warning_pulse_time) * 0.3
		oxygen_bar.modulate.a = pulse

	_update_player_stats()

func _update_player_stats() -> void:
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")
		if not player_ref:
			return

	# Update health
	var health_percent := player_ref.health / player_ref.max_health
	health_bar.max_value = player_ref.max_health
	health_bar.value = player_ref.health
	health_label.text = "HP: %d%%" % int(health_percent * 100)

	if health_percent <= 0.25:
		health_bar.modulate = CRITICAL_COLOR
	elif health_percent <= 0.5:
		health_bar.modulate = WARNING_COLOR
	else:
		health_bar.modulate = HEALTH_COLOR

	# Update inventory
	var item_count := player_ref.inventory.size()
	inventory_label.text = "ITEMS: %d" % item_count

	# Update threshold indicator
	threshold_indicator.visible = player_ref.in_threshold

func _on_resource_changed(resource_name: String, value: float, max_value: float) -> void:
	if resource_name == "oxygen":
		update_oxygen_display(value, max_value)

func update_oxygen_display(value: float, max_value: float) -> void:
	oxygen_bar.max_value = max_value
	oxygen_bar.value = value

	var percent := value / max_value
	oxygen_label.text = "O2: %d%%" % int(percent * 100)

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
	if depth_label:
		depth_label.text = "DEPTH: %d" % depth

func show_death_screen() -> void:
	death_panel.visible = true

func hide_death_screen() -> void:
	death_panel.visible = false

func _on_restart_pressed() -> void:
	GameManager.restart_game()
