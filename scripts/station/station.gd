extends Node2D

## Station: Hub scene for between-run upgrades and progression
## Handles material display, upgrade purchases, and dive initiation

const CALYX_CYAN := Color("#00ffff")
const CALYX_TEAL := Color("#40e0d0")
const CALYX_DARK := Color("#0a2020")

signal dive_requested

@onready var upgrade_panel: Control
@onready var material_display: Label
@onready var dive_button: Button

var upgrades_purchased: Dictionary = {}

func _ready() -> void:
	_load_progress()
	_create_station_ui()
	_create_background()
	_update_material_display()

	if not GameManager:
		push_error("[Station] _ready: GameManager autoload not found")

func _create_background() -> void:
	# Dark background
	var bg := ColorRect.new()
	bg.color = CALYX_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -100
	add_child(bg)

	# Grid pattern
	var grid := Node2D.new()
	grid.z_index = -99
	for x in range(-20, 21):
		var line := Line2D.new()
		line.points = PackedVector2Array([Vector2(x * 64, -720), Vector2(x * 64, 720)])
		line.width = 1.0
		line.default_color = Color(CALYX_TEAL, 0.05)
		grid.add_child(line)
	for y in range(-12, 13):
		var line := Line2D.new()
		line.points = PackedVector2Array([Vector2(-1280, y * 64), Vector2(1280, y * 64)])
		line.width = 1.0
		line.default_color = Color(CALYX_TEAL, 0.05)
		grid.add_child(line)
	add_child(grid)

	# Station title
	var title := Label.new()
	title.text = "SALVAGE STATION"
	title.position = Vector2(640 - 200, 40)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", CALYX_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(400, 50)
	add_child(title)

func _create_station_ui() -> void:
	# Material display (top right)
	var mat_container := HBoxContainer.new()
	mat_container.position = Vector2(1000, 40)

	var mat_icon := Polygon2D.new()
	mat_icon.polygon = PackedVector2Array([
		Vector2(0, -12), Vector2(10, -6), Vector2(10, 6),
		Vector2(0, 12), Vector2(-10, 6), Vector2(-10, -6)
	])
	mat_icon.color = Color("#ffd700")
	mat_icon.position = Vector2(0, 20)
	mat_container.add_child(mat_icon)

	material_display = Label.new()
	material_display.text = "0"
	material_display.add_theme_font_size_override("font_size", 28)
	material_display.add_theme_color_override("font_color", Color("#ffd700"))
	mat_container.add_child(material_display)
	add_child(mat_container)

	# Upgrade panel
	upgrade_panel = _create_upgrade_panel()
	upgrade_panel.position = Vector2(100, 150)
	add_child(upgrade_panel)

	# Dive button
	dive_button = Button.new()
	dive_button.text = "BEGIN DIVE"
	dive_button.custom_minimum_size = Vector2(200, 60)
	dive_button.position = Vector2(540, 600)
	dive_button.pressed.connect(_on_dive_pressed)
	add_child(dive_button)

func _create_upgrade_panel() -> Control:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(1080, 400)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(CALYX_DARK, 0.9)
	style.border_color = CALYX_CYAN
	style.set_border_width_all(2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 20
	scroll.offset_bottom = -20
	panel.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	scroll.add_child(grid)

	# Add upgrade cards
	var upgrades := _get_available_upgrades()
	for upgrade in upgrades:
		var card := _create_upgrade_card(upgrade)
		grid.add_child(card)

	return panel

func _create_upgrade_card(upgrade: Dictionary) -> Panel:
	if not upgrade.has("id") or not upgrade.has("name") or not upgrade.has("description"):
		push_error("[Station] _create_upgrade_card: Invalid upgrade dictionary")
		return Panel.new()  # Return empty panel on error

	if not upgrade.has("cost") or not upgrade.has("max_level"):
		push_error("[Station] _create_upgrade_card: Upgrade missing cost or max_level")
		return Panel.new()

	var card := Panel.new()
	card.custom_minimum_size = Vector2(340, 160)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(CALYX_DARK, 0.8)
	style.border_color = Color(CALYX_TEAL, 0.6)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 15
	vbox.offset_right = -15
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Upgrade name
	var name_label := Label.new()
	name_label.text = upgrade.name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", CALYX_CYAN)
	vbox.add_child(name_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = upgrade.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(CALYX_TEAL, 0.8))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Cost and buy button
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(bottom)

	var cost_label := Label.new()
	cost_label.text = "%d" % upgrade.cost
	cost_label.add_theme_font_size_override("font_size", 16)
	cost_label.add_theme_color_override("font_color", Color("#ffd700"))
	bottom.add_child(cost_label)

	var buy_btn := Button.new()
	buy_btn.text = "ACQUIRE"
	buy_btn.custom_minimum_size = Vector2(80, 30)
	buy_btn.pressed.connect(_on_upgrade_purchased.bind(upgrade))
	bottom.add_child(buy_btn)

	# Store reference for updating
	card.set_meta("upgrade_id", upgrade.id)
	card.set_meta("buy_button", buy_btn)
	card.set_meta("cost", upgrade.cost)

	# Check if already purchased
	var current_level: int = upgrades_purchased.get(upgrade.id, 0)
	if current_level >= upgrade.max_level:
		buy_btn.text = "MAX"
		buy_btn.disabled = true

	return card

func _get_available_upgrades() -> Array:
	return [
		{
			"id": "oxygen_capacity",
			"name": "O2 TANK UPGRADE",
			"description": "Increase maximum oxygen capacity by 20%",
			"cost": 100,
			"max_level": 5,
			"effect": "max_oxygen"
		},
		{
			"id": "health_boost",
			"name": "REINFORCED SUIT",
			"description": "Increase maximum health by 25",
			"cost": 150,
			"max_level": 4,
			"effect": "max_health"
		},
		{
			"id": "attack_power",
			"name": "WEAPON CALIBRATION",
			"description": "Increase attack damage by 10%",
			"cost": 200,
			"max_level": 5,
			"effect": "attack_damage"
		},
		{
			"id": "move_speed",
			"name": "SERVO MOTORS",
			"description": "Increase movement speed by 10%",
			"cost": 175,
			"max_level": 3,
			"effect": "move_speed"
		},
		{
			"id": "corruption_resist",
			"name": "DIVINE FILTER",
			"description": "Reduce corruption gained by 20%",
			"cost": 250,
			"max_level": 5,
			"effect": "corruption_resist"
		},
		{
			"id": "starting_items",
			"name": "SUPPLY CACHE",
			"description": "Start each run with an additional item",
			"cost": 300,
			"max_level": 2,
			"effect": "starting_items"
		}
	]

func _on_upgrade_purchased(upgrade: Dictionary) -> void:
	if not upgrade.has("id") or not upgrade.has("max_level") or not upgrade.has("cost"):
		push_error("[Station] _on_upgrade_purchased: Invalid upgrade dictionary")
		return

	var current_level: int = upgrades_purchased.get(upgrade.id, 0)
	if current_level >= upgrade.max_level:
		return

	if not GameManager:
		push_error("[Station] _on_upgrade_purchased: GameManager not available")
		return

	var cost: int = upgrade.cost * (current_level + 1)
	if cost < 0:
		push_warning("[Station] _on_upgrade_purchased: Cost overflow for %s" % upgrade.id)
		return

	if GameManager.total_material_banked < cost:
		return

	GameManager.total_material_banked -= cost
	upgrades_purchased[upgrade.id] = current_level + 1

	_update_material_display()
	_apply_upgrade(upgrade)
	_save_progress()

	# Refresh upgrade panel
	if upgrade_panel:
		upgrade_panel.queue_free()
	upgrade_panel = _create_upgrade_panel()
	if upgrade_panel:
		upgrade_panel.position = Vector2(100, 150)
		add_child(upgrade_panel)
	else:
		push_error("[Station] _on_upgrade_purchased: Failed to create upgrade panel")

func _apply_upgrade(upgrade: Dictionary) -> void:
	if not upgrade.has("id"):
		push_error("[Station] _apply_upgrade: Upgrade missing id")
		return

	# Upgrades are applied when starting a new run
	# Store in GameManager for persistence
	if GameManager:
		GameManager.set_upgrade_level(upgrade.id, upgrades_purchased.get(upgrade.id, 0))
	else:
		push_error("[Station] _apply_upgrade: GameManager not available")

func _update_material_display() -> void:
	if not material_display:
		push_warning("[Station] _update_material_display: material_display not initialized")
		return

	if GameManager:
		material_display.text = str(GameManager.total_material_banked)
	else:
		push_error("[Station] _update_material_display: GameManager not available")
		material_display.text = "0"

func _on_dive_pressed() -> void:
	dive_requested.emit()

	var tree := get_tree()
	if tree:
		var error := tree.change_scene_to_file("res://scenes/main.tscn")
		if error != OK:
			push_error("[Station] _on_dive_pressed: Failed to change scene (error: %d)" % error)
	else:
		push_error("[Station] _on_dive_pressed: SceneTree not available")

func _save_progress() -> void:
	if GameManager:
		GameManager.save_game()
	else:
		push_error("[Station] _save_progress: GameManager not available")

func _load_progress() -> void:
	if not GameManager:
		push_error("[Station] _load_progress: GameManager not available")
		return

	GameManager.load_game()
	upgrades_purchased = GameManager.get_all_upgrades()

	if upgrades_purchased == null:
		push_warning("[Station] _load_progress: get_all_upgrades returned null, using empty dict")
		upgrades_purchased = {}
