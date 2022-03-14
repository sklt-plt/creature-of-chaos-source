extends Timer

func _on_FalloutCheckerTimer_timeout():
	var td_visible = $"../TriggerDetector".visible_last
	var player = $"/root/Player"
	if not td_visible.empty() and player.global_transform.origin.y < td_visible[0].global_transform.origin.y - 500:

		var starting_room_geometry = get_node(get_tree().current_scene.find_node("starting_room").geometry) as RoomGeometry
		starting_room_geometry.move_to_offset()

		var spawn_point = get_tree().current_scene.get_node("PlayerSpawn")
		spawn_point._ready()  # recall player
