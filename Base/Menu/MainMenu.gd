extends Node

func _ready():
	#scene setup - globals override
	$"/root/Player".visible = false
	$"/root/Player".set("is_locked", true)
	$"/root/Player/HUD".visible = false
	$"/root/Player/BodyCollision/LookHeight/LookDirection/WorldCamera".current = false
	$"MenuCamera".current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	match $"/root/EpisodeManager".episode_clear_idx:
		1:
			$"UI".show_ep1_clear_notif()
		_:
			$"UI".show_main_menu()

func _on_UI_unsetup_menu():
	$"MenuCamera".current = false
	$"/root/Player".visible = true
	$"/root/Player".set("is_locked", false)
	$"/root/Player/BodyCollision/LookHeight/LookDirection/WorldCamera".current = true
	$"/root/Player/HUD".visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_UI_focus_camera(target_node):
	$"MenuCamera".set_target(get_node(target_node))
