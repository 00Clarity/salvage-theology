class_name ResourceSystem
extends Node

signal resource_changed(resource_name: String, value: float, max_value: float)
signal resource_depleted(resource_name: String)

@export var oxygen: float = 100.0
@export var max_oxygen: float = 100.0
@export var oxygen_drain_rate: float = 2.0  # Per second

var is_draining: bool = true

func _ready() -> void:
	# Defer to ensure listeners are ready
	call_deferred("_emit_initial_state")

func _emit_initial_state() -> void:
	resource_changed.emit("oxygen", oxygen, max_oxygen)

func _process(delta: float) -> void:
	if is_draining:
		drain_oxygen(delta)

func drain_oxygen(delta: float) -> void:
	var previous_oxygen := oxygen
	oxygen -= oxygen_drain_rate * delta
	oxygen = max(oxygen, 0.0)

	if oxygen != previous_oxygen:
		resource_changed.emit("oxygen", oxygen, max_oxygen)

	if oxygen <= 0.0 and previous_oxygen > 0.0:
		resource_depleted.emit("oxygen")

func restore_oxygen(amount: float) -> void:
	oxygen = min(oxygen + amount, max_oxygen)
	resource_changed.emit("oxygen", oxygen, max_oxygen)

func set_draining(enabled: bool) -> void:
	is_draining = enabled

func reset() -> void:
	oxygen = max_oxygen
	is_draining = true
	resource_changed.emit("oxygen", oxygen, max_oxygen)

func get_oxygen_percent() -> float:
	return oxygen / max_oxygen
