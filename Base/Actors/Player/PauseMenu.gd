extends PauseScreen

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		$Options.visible = false
		hide()

func _on_ResumeButton_button_up():
	hide()

func _on_QuitButton_button_up():
	$"/root/EpisodeManager".quit_to_menu()

func _on_OptionsButton_button_up():
	$Options.visible = true
