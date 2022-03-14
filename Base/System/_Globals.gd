tool
extends Node

var content_pack_path = "res://Content/default"

var player_progress = {
	"ep1_completed" : false
}

var applying_setings = false

var user_settings = {
	#video
	"screen_mode": 1,
	"resolution": 1.0,
	"vsync": true,
	"max_fps": 0,
	"antialiasing": 0,
	"sharpening": 0,
	"shadows": false,
	"ao": true,
	"fov": 90,
	#audio
	"master_volume": 1,
	"music_volume": 1,
	"effects_volume": 1,
	#controls
	"mouse_sensitivity": 0.225,
	"toggle_aim": false,
	"invert_run": true,
	#misc
	"legacy_campaign": false
}

const player_input_settings = {"Aim" : "", "Backwards" : "", "Crawl" : "", "Fire" : "", "Forward" : "", "Interact" : "",
	"Jump" : "", "Run" : "", "Select Revolver" : "", "Select Shotgun" : "", "Strafe Left" : "", "Strafe Right" : ""}

const USER_INPUT_FILENAME = "user://user_input.cfg"
const USER_SETTINGS_FILENAME = "user://user_settings.cfg"
const USER_PROGRESS_FILENAME = "user://user_progress.sav"

func set_ep_completed(var episode: String, var value : bool):
	player_progress[episode] = value
	save_user_progress()

func load_user_progress():
	if not FileHelper.load_file(USER_PROGRESS_FILENAME, player_progress):
		print("Can't load player progress")

func save_user_progress():
	FileHelper.save_file(USER_PROGRESS_FILENAME, player_progress)

func save_user_inputs():
	var to_save = {}
	for i in player_input_settings:
		var event = InputMap.get_action_list(i)[0]
		var as_text

		if event is InputEventMouseButton:
			as_text = "m"+String(event.button_index)
		elif event is InputEventKey:
			as_text = InputMap.get_action_list(i)[0].scancode

		to_save[i] = as_text

	FileHelper.save_file(USER_INPUT_FILENAME, to_save)

func load_user_inputs():
	#load game settings from file

	if not FileHelper.load_file(USER_INPUT_FILENAME, player_input_settings):
		print("Can't load user inputs, using defaults")
		return

	for setting in player_input_settings:
		var event
		if player_input_settings[setting] is String and player_input_settings[setting].begins_with("m"):
			event = InputEventMouseButton.new()
			event.button_index = int(player_input_settings[setting].substr(1))
		else:
			event = InputEventKey.new()
			event.scancode = int(player_input_settings[setting])

		InputHelper.set_input(setting, event)

func apply_user_settings(var new_settings : Dictionary):
	#chaos control
	if applying_setings:
		return

	applying_setings = true

	for setting in new_settings:
		#compare if anything changed
		if new_settings[setting] != user_settings[setting]:

			user_settings[setting] = new_settings[setting]

			#finally apply 'setting' that have changed
			#Lights handled when loading scene
			if setting == "screen_mode" or setting == "resolution":
				match int(user_settings["screen_mode"]):
					0:
						OS.window_fullscreen = true
					1:
						OS.window_fullscreen = false
						OS.window_borderless = false
					2:
						OS.window_fullscreen = false
						OS.window_borderless = true

				# if we try immediately apply resolution after switching screen mode, godot will override it
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")

				if OS.window_fullscreen:
					$"/root".size.x = user_settings["resolution"]*OS.window_size.x
					$"/root".size.y = user_settings["resolution"]*OS.window_size.y
				else:
					OS.window_size.x = OS.get_screen_size().x * 0.5 * user_settings["resolution"]
					OS.window_size.y = OS.get_screen_size().y * 0.5 * user_settings["resolution"]
					OS.center_window()

				var font_cache = get_node_or_null("/root/FontCache")
				if font_cache:
					for i in range(0, font_cache.font_default_sizes.size()):
						font_cache.font_resources[i].size = font_cache.font_default_sizes[i]*OS.window_size.y / 1000

			if setting == "vsync":
				OS.vsync_enabled = user_settings["vsync"]

			# no effect?
			if setting == "max_fps":
				ProjectSettings.set("application/run/frame_delay_msec", user_settings["max_fps"])

			if setting == "antialiasing":
				match int(user_settings["antialiasing"]):
					0:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_DISABLED
					1:
						get_viewport().fxaa = true
						get_viewport().msaa = Viewport.MSAA_DISABLED
					2:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_2X
					3:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_4X
					4:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_8X
					5:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_16X

			if setting == "sharpening":
				get_viewport().sharpen_intensity = user_settings["sharpening"]

			if setting == "shadows" or setting == "ao":
				var envs = get_tree().get_nodes_in_group("environment")
				for e in envs:
					e.update_to_settings()

			if setting == "fov":
				$"/root/Player".set_fov(user_settings["fov"])

			if setting == "master_volume":
				AudioServer.set_bus_volume_db(0, linear2db(user_settings["master_volume"]))

			if setting == "music_volume":
				AudioServer.set_bus_volume_db(1, linear2db(user_settings["music_volume"]))

			if setting == "effects_volume":
				AudioServer.set_bus_volume_db(2, linear2db(user_settings["effects_volume"]))

			if setting == "mouse_sensitivity":
				$"/root/Player/PlayerMovement".mouse_sensitivity = user_settings["mouse_sensitivity"]

			#"toggle_aim", "invert_run", "legacy_campaign" needs no special care

	applying_setings = false

func load_user_settings():
	#load game settings from file
	var loaded_settings = user_settings.duplicate()

	if FileHelper.load_file(USER_SETTINGS_FILENAME, loaded_settings):
		apply_user_settings(loaded_settings)

func save_user_settings():
	FileHelper.save_file(USER_SETTINGS_FILENAME, user_settings)
