class_name MaterialSpawner
extends RefCounted

const DivineMaterialScene := preload("res://scenes/systems/divine_material.tscn")

static func spawn_materials_for_room(room: Node2D, room_data: RoomData) -> Array[Node2D]:
	var materials: Array[Node2D] = []

	var material_count := _calculate_material_count(room_data)

	for i in range(material_count):
		var material := _create_material(room_data)
		if material:
			var spawn_pos := _get_spawn_position(room_data)
			material.position = spawn_pos
			room.add_child(material)
			materials.append(material)

	return materials

static func _calculate_material_count(room_data: RoomData) -> int:
	var base_count := 0

	match room_data.room_type:
		RoomData.RoomType.PASSAGE:
			base_count = randi_range(0, 1)
		RoomData.RoomType.CHAMBER:
			base_count = randi_range(1, 3)
		RoomData.RoomType.VAULT:
			base_count = randi_range(3, 6)  # Vault has most materials
		RoomData.RoomType.SANCTUM:
			base_count = randi_range(2, 4)
		RoomData.RoomType.HAZARD:
			base_count = randi_range(2, 4)  # High risk, high reward
		RoomData.RoomType.REST:
			base_count = randi_range(0, 1)  # Safe but few materials
		_:
			base_count = 1

	# Slight increase with depth
	if room_data.depth >= 6:
		base_count += 1
	if room_data.depth >= 9:
		base_count += 1

	return base_count

static func _create_material(room_data: RoomData) -> DivineMaterial:
	return DivineMaterial.create_random(room_data.depth)

static func _get_spawn_position(room_data: RoomData) -> Vector2:
	var half_w := room_data.width * 32 / 2.0 - 64
	var half_h := room_data.height * 32 / 2.0 - 64

	return Vector2(
		randf_range(-half_w, half_w),
		randf_range(-half_h, half_h)
	)
