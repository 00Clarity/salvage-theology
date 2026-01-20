class_name EnemySpawner
extends RefCounted

const WatcherScene := preload("res://scenes/enemies/echo_watcher.tscn")
const SeekerScene := preload("res://scenes/enemies/echo_seeker.tscn")

static func spawn_enemies_for_room(room: Node2D, room_data: RoomData) -> Array[Node2D]:
	var enemies: Array[Node2D] = []

	# Don't spawn enemies in REST rooms
	if room_data.room_type == RoomData.RoomType.REST:
		return enemies

	var enemy_count := _calculate_enemy_count(room_data)

	for i in range(enemy_count):
		var enemy := _create_enemy(room_data)
		if enemy:
			var spawn_pos := _get_spawn_position(room_data)
			enemy.global_position = spawn_pos
			room.add_child(enemy)
			enemies.append(enemy)

	return enemies

static func _calculate_enemy_count(room_data: RoomData) -> int:
	var base_count := 0

	match room_data.room_type:
		RoomData.RoomType.PASSAGE:
			base_count = randi_range(0, 1)
		RoomData.RoomType.CHAMBER:
			base_count = randi_range(2, 4)
		RoomData.RoomType.VAULT:
			base_count = randi_range(1, 2)
		RoomData.RoomType.SANCTUM:
			base_count = randi_range(1, 2)
		RoomData.RoomType.HAZARD:
			base_count = randi_range(1, 3)
		_:
			base_count = 0

	# Increase with depth
	var depth_bonus := room_data.depth / 3
	return base_count + depth_bonus

static func _create_enemy(room_data: RoomData) -> Node2D:
	var roll := randf()

	# Enemy type distribution based on depth
	if room_data.depth <= 2:
		# Entry zone: mostly watchers
		return WatcherScene.instantiate()
	elif room_data.depth <= 5:
		# Outer sanctum: mix
		if roll < 0.6:
			return WatcherScene.instantiate()
		else:
			return SeekerScene.instantiate()
	else:
		# Deep: more seekers
		if roll < 0.4:
			return WatcherScene.instantiate()
		else:
			return SeekerScene.instantiate()

static func _get_spawn_position(room_data: RoomData) -> Vector2:
	var half_w := room_data.width * 32 / 2.0 - 64
	var half_h := room_data.height * 32 / 2.0 - 64

	return Vector2(
		randf_range(-half_w, half_w),
		randf_range(-half_h, half_h)
	)
