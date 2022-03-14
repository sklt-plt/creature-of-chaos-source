extends Node

var current_ep = -1
var episode_levels
var current_level_idx
var episode_clear_idx = -1

func reset_episode_cache():
	current_ep = -1
	episode_levels = []
	current_level_idx = -1

func next_map_in_ep():
	current_level_idx += 1
	var path = Globals.content_pack_path + "/Maps/Levels/ep" + String(current_ep) + "/map" + String(current_level_idx) + ".tscn"
	return change_map(path)

func next_map():
	$"/root/Player".give("s_level", 1)

	match current_ep:
		1:
			next_map_in_ep()
		101:
			#endless episode
			restart_current_map()
		201:
			#custom map episode
			restart_episode()

func restart_episode():
	start_episode(current_ep)

func restart_current_map():
	current_level_idx -= 1
	next_map_in_ep()

func change_map(var map_path: String):
	#flush caches
	$"/root/AIManager".clear_registrations()
	$"/root/Player".get_node("TriggerDetector").flush_cache()
	$"/root/Player".show_loading()
	yield(get_tree().create_timer(0.05), "timeout")

	if get_tree().change_scene(map_path) != OK:
		if current_ep == 1:
			$"/root/Player".hide_loading()
			if not Globals.player_progress["ep1_completed"] :
				Globals.set_ep_completed("ep1_completed", true)
				episode_clear_idx = 1

			$"/root/Player/GameOverStats".show()

		print("Can't load level: ", map_path)
		return false

	return true

func quit_to_menu():
	get_tree().paused = false
	$"/root/Player".reset()
	$"/root/Player".hide_loading()
	$"/root/Player/PauseMenu".visible = false
	$"/root/Player/GameOver".visible = false
	$"/root/Player/MusicController".crossfade_next_list([])
	$"/root/Player".get_node("TriggerDetector").flush_cache()
	$"/root/AIManager".clear_registrations()
	if get_tree().change_scene(Globals.content_pack_path + "/MainMenu/MainMenu.tscn") != OK:
		print("Can't load: ", Globals.content_pack_path + "/MainMenu/MainMenu.tscn")

func start_episode(var ep_idx: int):
	reset_episode_cache()
	$"/root/Player".reset()
	current_ep = ep_idx

	if is_endless_episode_playing():
		$"/root/Player".start_arcade_mode()

	next_map_in_ep()

func is_normal_episode_playing():
	return current_ep < 100

func is_endless_episode_playing():
	return current_ep >= 100 and current_ep < 200

func is_custom_episode_playing():
	return current_ep >= 200
