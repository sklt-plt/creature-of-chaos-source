extends PauseScreen
class_name GameOver

func show_delayed():
	$"DelayT".start()

func show():
	$"DelayT".stop()
	.show()

func _on_RestartB_button_up():
	$"/root/Player".revive()
	hide()
	$"/root/EpisodeManager".restart_current_map()

func _on_QuitB_button_up():
	hide()
	$"/root/EpisodeManager".quit_to_menu()

func _on_DelayT_timeout():
	show()
