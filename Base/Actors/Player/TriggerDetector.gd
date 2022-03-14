extends Area

var visible_last = []

func flush_cache():
	visible_last = []

func get_visible_and_enable_visible_link(var link):
	var visible_link = get_node(link)
	visible_link.move_to_offset()
	return visible_link

func _on_TriggerDetector_area_entered(area):
	var parent = area.get_parent()

	if parent is RoomGeometry:
		var mg = get_tree().get_current_scene().find_node("MapGenerator")
		if not mg.is_generating():
			var visible_now = []
			visible_now.push_back(parent)

			if parent.north_link.has("target") and parent.north_link["target"] != "outside":
				visible_now.push_back(get_visible_and_enable_visible_link(parent.north_link["target"]))
			if parent.south_link.has("target") and parent.south_link["target"] != "outside":
				visible_now.push_back(get_visible_and_enable_visible_link(parent.south_link["target"]))
			if parent.west_link.has("target") and parent.west_link["target"] != "outside":
				visible_now.push_back(get_visible_and_enable_visible_link(parent.west_link["target"]))
			if parent.east_link.has("target") and parent.east_link["target"] != "outside":
				visible_now.push_back(get_visible_and_enable_visible_link(parent.east_link["target"]))

			var i = 0
			while i < visible_last.size():
				if not visible_now.has(visible_last[i]):
					visible_last[i].move_away()
				i += 1

			visible_last = visible_now
