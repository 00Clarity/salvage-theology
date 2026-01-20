extends Node

signal game_over
signal game_restarted

enum GameState { PLAYING, DEAD, PAUSED }

var current_state: GameState = GameState.PLAYING
var player: CharacterBody2D

func _ready() -> void:
	pass

func register_player(p: CharacterBody2D) -> void:
	player = p

func trigger_death() -> void:
	if current_state == GameState.DEAD:
		return
	current_state = GameState.DEAD
	emit_signal("game_over")

func restart_game() -> void:
	current_state = GameState.PLAYING
	emit_signal("game_restarted")
	get_tree().reload_current_scene()

func is_playing() -> bool:
	return current_state == GameState.PLAYING
