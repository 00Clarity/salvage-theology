extends Node2D

@onready var hud = $HUD
@onready var resource_system = $ResourceSystem

func _on_resource_depleted(resource_name: String) -> void:
	if resource_name == "oxygen":
		resource_system.set_draining(false)
		GameManager.trigger_death()
		hud.show_death_screen()
