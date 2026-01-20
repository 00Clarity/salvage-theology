class_name RunSummary
extends CanvasLayer

signal continue_pressed
signal restart_pressed

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")
const CALYX_DARK := Color("#0a2020")

var panel: Panel
var title_label: Label
var stats_container: VBoxContainer
var material_label: VBoxContainer
var depth_label: VBoxContainer
var rooms_label: VBoxContainer
var enemies_label: VBoxContainer
var sacrifices_label: VBoxContainer
var banked_label: VBoxContainer
var continue_button: Button
var restart_button: Button

var is_extraction: bool = false

func _ready() -> void:
	visible = false
	_create_ui()
	GameManager.extraction_complete.connect(_on_extraction_complete)
	GameManager.game_over.connect(_on_game_over)

func _create_ui() -> void:
	# Background overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Main panel
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 500)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -250
	panel.offset_bottom = 250

	var style := StyleBoxFlat.new()
	style.bg_color = CALYX_DARK
	style.border_color = CALYX_CYAN
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# Content container
	var container := VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.offset_left = 30
	container.offset_right = -30
	container.offset_top = 30
	container.offset_bottom = -30
	container.add_theme_constant_override("separation", 16)
	panel.add_child(container)

	# Title
	title_label = Label.new()
	title_label.text = "RUN COMPLETE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", CALYX_CYAN)
	container.add_child(title_label)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_color_override("separator", Color(CALYX_CYAN, 0.5))
	container.add_child(sep)

	# Stats container
	stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 12)
	container.add_child(stats_container)

	# Material collected (big)
	material_label = _create_stat_label("MATERIAL SALVAGED", "0", 22)
	stats_container.add_child(material_label)

	# Depth reached
	depth_label = _create_stat_label("DEPTH REACHED", "1", 16)
	stats_container.add_child(depth_label)

	# Rooms explored
	rooms_label = _create_stat_label("ROOMS EXPLORED", "0", 16)
	stats_container.add_child(rooms_label)

	# Enemies defeated
	enemies_label = _create_stat_label("ECHOES SILENCED", "0", 16)
	stats_container.add_child(enemies_label)

	# Sacrifices made
	sacrifices_label = _create_stat_label("SACRIFICES MADE", "0", 16)
	stats_container.add_child(sacrifices_label)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	container.add_child(spacer)

	# Total banked
	banked_label = _create_stat_label("TOTAL BANKED", "0", 18)
	# Set gold color on the value label inside the container
	var banked_value_lbl: Label = banked_label.get_node("Value")
	if banked_value_lbl:
		banked_value_lbl.add_theme_color_override("font_color", Color("#ffd700"))
	container.add_child(banked_label)

	# Button container
	var button_container := HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	container.add_child(button_container)

	# Continue button (only for extraction)
	continue_button = Button.new()
	continue_button.text = "TO STATION"
	continue_button.custom_minimum_size = Vector2(140, 40)
	continue_button.pressed.connect(_on_continue_pressed)
	button_container.add_child(continue_button)

	# Restart button
	restart_button = Button.new()
	restart_button.text = "NEW RUN"
	restart_button.custom_minimum_size = Vector2(140, 40)
	restart_button.pressed.connect(_on_restart_pressed)
	button_container.add_child(restart_button)

func _create_stat_label(title: String, value: String, font_size: int) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)

	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(CALYX_TEAL, 0.8))
	container.add_child(title_lbl)

	var value_lbl := Label.new()
	value_lbl.name = "Value"
	value_lbl.text = value
	value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_lbl.add_theme_font_size_override("font_size", font_size)
	value_lbl.add_theme_color_override("font_color", CALYX_CYAN)
	container.add_child(value_lbl)

	return container

func show_summary(summary: Dictionary, extraction: bool) -> void:
	is_extraction = extraction
	visible = true

	if extraction:
		title_label.text = "EXTRACTION COMPLETE"
		title_label.add_theme_color_override("font_color", Color("#00ff00"))
		continue_button.visible = true
	else:
		title_label.text = "SIGNAL LOST"
		title_label.add_theme_color_override("font_color", Color("#ff4444"))
		continue_button.visible = false

	# Update stats
	_update_stat(material_label, str(summary.get("material_collected", 0)))
	_update_stat(depth_label, str(summary.get("depth_reached", 1)))
	_update_stat(rooms_label, str(summary.get("rooms_visited", 0)))
	_update_stat(enemies_label, str(summary.get("enemies_killed", 0)))

	var total_sacrifices: int = summary.get("items_sacrificed", 0) + summary.get("memories_sacrificed", 0)
	_update_stat(sacrifices_label, str(total_sacrifices))

	_update_stat(banked_label, str(summary.get("total_banked", 0)))

	# Animate in
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.parallel().tween_property(panel, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.3)

func _update_stat(container: VBoxContainer, value: String) -> void:
	var value_label: Label = container.get_node("Value")
	if value_label:
		value_label.text = value

func _on_extraction_complete(summary: Dictionary) -> void:
	show_summary(summary, true)

func _on_game_over() -> void:
	var summary := GameManager.get_run_summary()
	show_summary(summary, false)

func _on_continue_pressed() -> void:
	visible = false
	continue_pressed.emit()

func _on_restart_pressed() -> void:
	visible = false
	restart_pressed.emit()
	GameManager.restart_game()
