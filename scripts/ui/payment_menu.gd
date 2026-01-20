class_name PaymentMenu
extends CanvasLayer

## PaymentMenu: UI for door sacrifice options
## Displays available payment types and handles player selection

signal payment_selected(payment_type: TheologyDoor.PaymentType)
signal payment_cancelled

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")
const CALYX_DARK := Color("#0a2020")

var panel: Panel
var title_label: Label
var options_container: VBoxContainer
var cancel_button: Button
var current_door: TheologyDoor

func _ready() -> void:
	_create_ui()
	hide_menu()

func _create_ui() -> void:
	# Main panel
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(280, 200)
	panel.offset_left = -140
	panel.offset_top = -100
	panel.offset_right = 140
	panel.offset_bottom = 100

	var style := StyleBoxFlat.new()
	style.bg_color = Color(CALYX_DARK, 0.95)
	style.border_color = CALYX_CYAN
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# Content container
	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 16
	content.offset_top = 16
	content.offset_right = -16
	content.offset_bottom = -16
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	# Title
	title_label = Label.new()
	title_label.text = "PASSAGE REQUIRES SACRIFICE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", CALYX_CYAN)
	title_label.add_theme_font_size_override("font_size", 16)
	content.add_child(title_label)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_color_override("separator_color", Color(CALYX_TEAL, 0.5))
	content.add_child(sep)

	# Options container
	options_container = VBoxContainer.new()
	options_container.add_theme_constant_override("separation", 8)
	content.add_child(options_container)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	# Cancel button
	cancel_button = Button.new()
	cancel_button.text = "RETREAT"
	cancel_button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	cancel_button.add_theme_font_size_override("font_size", 12)
	cancel_button.pressed.connect(_on_cancel_pressed)
	content.add_child(cancel_button)

func show_menu(door: TheologyDoor) -> void:
	if not door:
		push_error("[PaymentMenu] show_menu: door is null")
		return

	current_door = door
	_clear_options()

	if not door.has_method("request_payment"):
		push_error("[PaymentMenu] show_menu: door missing request_payment method")
		return

	var options := door.request_payment()

	if not options_container:
		push_error("[PaymentMenu] show_menu: options_container not initialized")
		return

	if options.is_empty():
		# No valid payment options - show warning
		var warning := Label.new()
		warning.text = "You have nothing to offer..."
		warning.add_theme_color_override("font_color", Color("#ff6600"))
		warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		options_container.add_child(warning)
	else:
		for option in options:
			if not option is Dictionary:
				push_warning("[PaymentMenu] show_menu: Invalid option type")
				continue
			var btn := _create_option_button(option)
			if btn:
				options_container.add_child(btn)

	visible = true
	var tree := get_tree()
	if tree:
		tree.paused = true
	else:
		push_warning("[PaymentMenu] show_menu: SceneTree not available")

func hide_menu() -> void:
	visible = false
	var tree := get_tree()
	if tree:
		tree.paused = false
	else:
		push_warning("[PaymentMenu] hide_menu: SceneTree not available")
	current_door = null

func _clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

func _create_option_button(option: Dictionary) -> Button:
	if not option.has("label") or not option.has("description") or not option.has("type"):
		push_error("[PaymentMenu] _create_option_button: Invalid option dictionary, missing required keys")
		return null

	var btn := Button.new()
	btn.text = option.label
	btn.tooltip_text = option.description
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Style
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color(CALYX_DARK, 0.8)
	style_normal.border_color = CALYX_TEAL
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(2)
	btn.add_theme_stylebox_override("normal", style_normal)

	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = Color(CALYX_TEAL, 0.3)
	style_hover.border_color = CALYX_CYAN
	style_hover.set_border_width_all(2)
	style_hover.set_corner_radius_all(2)
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.add_theme_color_override("font_color", CALYX_CYAN)
	btn.add_theme_font_size_override("font_size", 14)

	# Color by payment type
	var type_color: Color = CALYX_CYAN  # Default
	match option.type:
		TheologyDoor.PaymentType.ITEM:
			type_color = Color("#ffd700")
		TheologyDoor.PaymentType.HEALTH:
			type_color = Color("#ff4444")
		TheologyDoor.PaymentType.MEMORY:
			type_color = Color("#e6e6fa")
		_:
			push_warning("[PaymentMenu] _create_option_button: Unknown payment type %s" % option.type)

	btn.add_theme_color_override("font_color", type_color)

	btn.pressed.connect(_on_option_selected.bind(option.type))
	return btn

func _on_option_selected(payment_type: TheologyDoor.PaymentType) -> void:
	if current_door:
		if current_door.has_method("execute_payment"):
			var success := current_door.execute_payment(payment_type)
			if success:
				payment_selected.emit(payment_type)
		else:
			push_error("[PaymentMenu] _on_option_selected: current_door missing execute_payment method")
	else:
		push_warning("[PaymentMenu] _on_option_selected: No current_door set")

	hide_menu()

func _on_cancel_pressed() -> void:
	payment_cancelled.emit()
	hide_menu()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
