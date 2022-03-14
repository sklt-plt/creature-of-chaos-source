extends Control

export (PackedScene) var soundtrack_node

const SETTINGS_FILENAME = "user://custom_map_settings.cfg"

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"/root/Player/MusicController".crossfade_next_list([])

	var to_load = {
		"gen_seed" : "",
		"make_ceilings" : "",
		"main_path_length": "",
		"sub_path_max_length": "",
		"num_of_sub_paths": "",
		"min_room_size": "",
		"max_room_size": "",
		"min_room_height": "",
		"max_room_height": "",
		"_average_room_difficulty": "",
		"_average_difficulty_variation": "",
		"_max_random_walks": "",
		"_random_walks_widths": "",
		"_arena_obstacle_per_quadrant": "",
		"_arena_obstacle_outline_thickness": "",
		"_arena_obstacle_min_size": "",
		"_arena_obstacle_max_size": "",
		"use_prefabs": "",
		"_prefabs_on_main": ""
	}

	if FileHelper.load_file(SETTINGS_FILENAME, to_load):
		$"SC/GC/SeedLE".text = to_load["gen_seed"]
		$"SC/GC/CeilingsB".pressed = to_load["make_ceilings"]
		$"SC/GC/MainLengthSB".value = to_load["main_path_length"]
		$"SC/GC/SubLengthSB".value = to_load["sub_path_max_length"]
		$"SC/GC/SubPathNumSB".value = to_load["num_of_sub_paths"]
		$"SC/GC/RoomSizeBarsGC/MinSB".value = to_load["min_room_size"]
		$"SC/GC/RoomSizeBarsGC/MaxSB".value = to_load["max_room_size"]
		$"SC/GC/RoomHeightGC/MinSB".value = to_load["min_room_height"]
		$"SC/GC/RoomHeightGC/MaxSB".value = to_load["max_room_height"]
		$"SC/GC/AvgRoomDifficultySB".value = to_load["_average_room_difficulty"]
		$"SC/GC/AvgDifficultyDeviationSB".value = to_load["_average_difficulty_variation"]
		$"SC/GC/MaxRandomWalksSB".value = to_load["_max_random_walks"]
		$"SC/GC/RandomWalksWidthsO".selected = to_load["_random_walks_widths"]
		$"SC/GC/ArenaObstacleNumSB".value = to_load["_arena_obstacle_per_quadrant"]*4
		$"SC/GC/ArenaObstacleMarginSB".value = to_load["_arena_obstacle_outline_thickness"]
		$"SC/GC/ArenaObstacleGC/MinSB".value = to_load["_arena_obstacle_min_size"]
		$"SC/GC/ArenaObstacleGC/MaxSB".value = to_load["_arena_obstacle_max_size"]
		$"SC/GC/UseSpecialRoomsB".pressed = to_load["use_prefabs"]
		$"SC/GC/SpecialsOnMainB".pressed = to_load["_prefabs_on_main"]

func _on_PlayButton_button_up():
	#check if this child of GeneratorOverrides
	var overrides = self.get_parent()
	if not overrides is GeneratorOverrides:
		print("This node must be child of GeneratorOverrides")
		return

	var to_save = {}

	overrides.gen_seed = $"SC/GC/SeedLE".text
	to_save["gen_seed"] = overrides.gen_seed

	overrides.make_ceilings = $"SC/GC/CeilingsB".pressed
	to_save["make_ceilings"] = overrides.make_ceilings

	overrides.main_path_length = $"SC/GC/MainLengthSB".value
	to_save["main_path_length"] = overrides.main_path_length

	overrides.sub_path_max_length = $"SC/GC/SubLengthSB".value
	to_save["sub_path_max_length"] = overrides.sub_path_max_length

	overrides.num_of_sub_paths = $"SC/GC/SubPathNumSB".value
	to_save["num_of_sub_paths"] = overrides.num_of_sub_paths

	overrides.min_room_size = $"SC/GC/RoomSizeBarsGC/MinSB".value
	to_save["min_room_size"] = overrides.min_room_size

	overrides.max_room_size = $"SC/GC/RoomSizeBarsGC/MaxSB".value
	to_save["max_room_size"] = overrides.max_room_size

	overrides.min_room_height = $"SC/GC/RoomHeightGC/MinSB".value
	to_save["min_room_height"] = overrides.min_room_height

	overrides.max_room_height = $"SC/GC/RoomHeightGC/MaxSB".value
	to_save["max_room_height"] = overrides.max_room_height

	overrides._average_room_difficulty = $"SC/GC/AvgRoomDifficultySB".value
	to_save["_average_room_difficulty"] = overrides._average_room_difficulty

	overrides._average_difficulty_variation = $"SC/GC/AvgDifficultyDeviationSB".value
	to_save["_average_difficulty_variation"] = overrides._average_difficulty_variation

	overrides._max_random_walks = $"SC/GC/MaxRandomWalksSB".value
	to_save["_max_random_walks"] = overrides._max_random_walks

	overrides._random_walks_widths = $"SC/GC/RandomWalksWidthsO".selected
	to_save["_random_walks_widths"] = overrides._random_walks_widths

	overrides._arena_obstacle_per_quadrant = $"SC/GC/ArenaObstacleNumSB".value / 4
	to_save["_arena_obstacle_per_quadrant"] = overrides._arena_obstacle_per_quadrant

	overrides._arena_obstacle_outline_thickness = $"SC/GC/ArenaObstacleMarginSB".value
	to_save["_arena_obstacle_outline_thickness"] = overrides._arena_obstacle_outline_thickness

	overrides._arena_obstacle_min_size = $"SC/GC/ArenaObstacleGC/MinSB".value
	to_save["_arena_obstacle_min_size"] = overrides._arena_obstacle_min_size

	overrides._arena_obstacle_max_size = $"SC/GC/ArenaObstacleGC/MaxSB".value
	to_save["_arena_obstacle_max_size"] = overrides._arena_obstacle_max_size

	overrides.use_prefabs = $"SC/GC/UseSpecialRoomsB".pressed
	to_save["use_prefabs"] = overrides.use_prefabs

	overrides._prefabs_on_main = $"SC/GC/SpecialsOnMainB".pressed
	to_save["_prefabs_on_main"] = overrides._prefabs_on_main

	FileHelper.save_file(SETTINGS_FILENAME, to_save)

	overrides.done = true

	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if soundtrack_node:
		get_parent().add_child(soundtrack_node.instance())

func _on_ExitButton_button_up():
	$"/root/EpisodeManager".quit_to_menu()

func _on_MaxSB_value_changed(_value):
	#validate all max inputs and adjust pair min value if needed
	var room_min_size_sb = $"SC/GC/RoomSizeBarsGC/MinSB"
	var room_max_size_sb = $"SC/GC/RoomSizeBarsGC/MaxSB"

	if room_max_size_sb.value < room_min_size_sb.value:
		room_min_size_sb.value = room_max_size_sb.value

	var room_min_heigth_sb = $"SC/GC/RoomHeightGC/MinSB"
	var room_max_heigth_sb = $"SC/GC/RoomHeightGC/MaxSB"

	if room_max_heigth_sb.value < room_min_heigth_sb.value:
		room_min_heigth_sb.value = room_max_heigth_sb.value

	var arena_obstacle_min_s_sb = $"SC/GC/ArenaObstacleGC/MinSB"
	var arena_obstacle_max_s_sb = $"SC/GC/ArenaObstacleGC/MaxSB"

	if arena_obstacle_max_s_sb.value < arena_obstacle_min_s_sb.value:
		arena_obstacle_min_s_sb.value = arena_obstacle_max_s_sb.value

func _on_MinSB_value_changed(_value):
	#validate all min inputs and adjust pair max value if needed
	var room_min_size_sb = $"SC/GC/RoomSizeBarsGC/MinSB"
	var room_max_size_sb = $"SC/GC/RoomSizeBarsGC/MaxSB"

	if room_min_size_sb.value > room_max_size_sb.value:
		room_max_size_sb.value = room_min_size_sb.value

	var room_min_heigth_sb = $"SC/GC/RoomHeightGC/MinSB"
	var room_max_heigth_sb = $"SC/GC/RoomHeightGC/MaxSB"

	if room_min_heigth_sb.value > room_max_heigth_sb.value:
		room_max_heigth_sb.value = room_min_heigth_sb.value

	var arena_obstacle_min_s_sb = $"SC/GC/ArenaObstacleGC/MinSB"
	var arena_obstacle_max_s_sb = $"SC/GC/ArenaObstacleGC/MaxSB"

	if arena_obstacle_min_s_sb.value > arena_obstacle_max_s_sb.value:
		arena_obstacle_max_s_sb.value = arena_obstacle_min_s_sb.value

func _on_AvgRoomDifficultySB_value_changed(value):
	#max deviation cannot be highier than max difficulty, because we might get negative values for rooms
	var deviation = $"SC/GC/AvgDifficultyDeviationSB"
	deviation.max_value = value
