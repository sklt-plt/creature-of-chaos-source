extends Control

signal unsetup_menu
signal focus_camera (target_node)

export (String) var readme_dir = "/README"
export (String) var feedback_url = ""

func _ready():
	$"LevelSelect/Ep2Button".disabled = true #!Globals.ep1_completed  # unavailable yet
	$"LevelSelect/Ep3Button".disabled = true #!Globals.ep2_completed  # unavailable yet
	$"LevelSelectEp1/PlayEp1Endless".disabled = !Globals.player_progress["ep1_completed"]
	$"LevelSelectEp1/PlayEp1Custom".disabled = !Globals.player_progress["ep1_completed"]
	$"Options".visible = false
	$"LevelSelectEp1".visible = false
	$"LevelSelect".visible = false

func show_ep1_clear_notif():
	$"/root/EpisodeManager".episode_clear_idx = -1
	$"MainMenu".visible = false
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionMain")
	$"LevelSelectEp1".visible = false
	$"Options".visible = false
	$"Ep1ClearNotif".visible = true

func show_main_menu():
	$"MainMenu".visible = true
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionMain")
	$"LevelSelectEp1".visible = false
	$"Options".visible = false
	$"Ep1ClearNotif".visible = false

func show_options():
	$"MainMenu".visible = false
	$"Options".visible = true

func show_level_select():
	$"MainMenu".visible = false
	$"LevelSelect".visible = true
	$"LevelSelectEp1".visible = false
	emit_signal("focus_camera", "CameraPositionMain")

func show_ep1():
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionEp1")
	$"LevelSelectEp1".visible = true

func _on_NewGameButton_button_up():
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(0)

func _on_LSBackButton_button_up():
	show_main_menu()

func _on_ContinueButton_button_up():
	show_level_select()

func _on_PlayEp1_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(1)

func _on_PlayEp1Endless_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(101)

func _on_PlayEp1Custom_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(201)

func _on_Ep1Button_button_up():
	show_ep1()

func _on_LSE1BackButton_button_up():
	show_level_select()

func _on_QuitButton_button_up():
	get_tree().quit()

func _on_OptionsButton_button_up():
	show_options()

func _on_Options_exited():
	show_main_menu()

func _on_ManualButton_button_up():
	if readme_dir != "":
		OS.shell_open(OS.get_executable_path().get_base_dir().plus_file(ProjectSettings.globalize_path(Globals.content_pack_path) + readme_dir))

func _on_Ep1ClearOkButton_button_up():
	show_main_menu()

func _on_Button_button_up():
	if readme_dir != "":
		OS.shell_open(feedback_url)
