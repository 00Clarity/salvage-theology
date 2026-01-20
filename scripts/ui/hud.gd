extends CanvasLayer

const NORMAL_COLOR := Color(0, 1, 1, 0.9)      # Cyan
const WARNING_COLOR := Color(1, 0.5, 0, 0.9)    # Orange
const CRITICAL_COLOR := Color(1, 0, 0, 0.9)     # Red

@onready var oxygen_bar: ProgressBar = $OxygenContainer/OxygenBar
@onready var oxygen_label: Label = $OxygenContainer/OxygenLabel
@onready var death_panel: Panel = $DeathPanel
@onready var restart_button: Button = $DeathPanel/VBoxContainer/RestartButton

var warning_pulse_time: float = 0.0
var is_warning: bool = false

func _ready() -> void:
	death_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func _process(delta: float) -> void:
	if is_warning:
		warning_pulse_time += delta * 4.0
		var pulse := 0.7 + sin(warning_pulse_time) * 0.3
		oxygen_bar.modulate.a = pulse

func _on_resource_changed(resource_name: String, value: float, max_value: float) -> void:
	if resource_name == "oxygen":
		update_oxygen_display(value, max_value)

func update_oxygen_display(value: float, max_value: float) -> void:
	oxygen_bar.max_value = max_value
	oxygen_bar.value = value

	var percent := value / max_value
	oxygen_label.text = "O2: %d%%" % int(percent * 100)

	# Color based on level
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

func show_death_screen() -> void:
	death_panel.visible = true

func hide_death_screen() -> void:
	death_panel.visible = false

func _on_restart_pressed() -> void:
	GameManager.restart_game()
