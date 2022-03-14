extends Camera

func flash_cache_objects():
	#flash objects infront of player to compile shaders
	var cache = get_node_or_null("/root/ObjectCache")
	if not cache:
		print("Warning: not found '/root/ObjectCache', can't precompile shaders")
		return

	#borrow it from root
	for c in cache.children_cache:
		self.add_child(c)

	get_tree().paused = true
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	$"/root/Player".hide_loading()

	for c in cache.children_cache:
		self.remove_child(c)
