extends Node
class_name InputProxy

var is_locked = false

var player_movement_node
var player_animation_node

var proxy_joy = Vector2()
var proxy_fire
var proxy_just_fired
var proxy_alt_fire_just_pressed
var proxy_alt_fire_just_released
var proxy_select
var proxy_select_ind = 0
var proxy_select_next
var proxy_select_prev
var proxy_run
var proxy_jump
var proxy_crawl

func _ready():
	player_movement_node = get_parent().get_node("PlayerMovement");
	player_animation_node = get_parent().get_node("PlayerAnimations");

func _unhandled_input(event_):
	#cheats :
	if (Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
		&& get_tree().get_current_scene().get_name() != "MainMenu"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if $"../PlayerResources".check("r_health") > 0.0:
			$"../PauseMenu".show()

	if $"../PlayerResources".check("r_health") <= 0.0:
		if $"/root/EpisodeManager".is_normal_episode_playing():
			$"../GameOver".show()
		else:
			$"../GameOverStats".show()

	if Input.is_action_pressed("DBG_ENABLE"):
		if Input.is_action_just_pressed("DBG_1"):
			if not $"../PlayerMovement".is_flying:
				get_node("/root/Player").start_flying()
				get_node("/root/Player/BodyCollision").disabled = true
				print("Noclip on")
			else:
				get_node("/root/Player").stop_flying()
				get_node("/root/Player/BodyCollision").disabled = false
				print("Noclip off")

		if Input.is_action_just_pressed("DBG_2"):
			$"/root/Player".play_slowmo_effect()

		if Input.is_action_just_pressed("DBG_3"):
			Globals.set_ep_completed("ep1_completed", not Globals.player_progress["ep1_completed"])
			EpisodeManager.change_map(Globals.content_pack_path + "/MainMenu/MainMenu.tscn")
			$"/root/Player".hide_loading()

		if Input.is_action_just_pressed("DBG_4"):
			$"/root/Player".give("e_double_barrel_level", 1)
			$"/root/Player".give("r_pistol_ammo", 100)
			$"/root/Player".give("r_shotgun_ammo", 100)
			$"/root/Player".give("r_health", 100)
			$"/root/Player".give("r_armor", 100)

		if Input.is_action_just_pressed("DBG_5"):
			EpisodeManager.next_map()

func _physics_process(_delta):
	if not is_locked:
		proxy_jump = Input.is_action_pressed("Jump")
		proxy_crawl = Input.is_action_pressed("Crawl")
		proxy_run = Input.is_action_pressed("Run")
		proxy_fire = Input.is_action_pressed("Fire")
		proxy_just_fired = Input.is_action_just_pressed("Fire")
		proxy_alt_fire_just_pressed = Input.is_action_just_pressed("Aim")
		proxy_alt_fire_just_released = Input.is_action_just_released("Aim")
		proxy_select = Input.is_action_just_pressed("Select Revolver") or Input.is_action_just_pressed("Select Shotgun")
		if Input.is_action_just_pressed("Select Revolver"):
			proxy_select_ind = 0
		if Input.is_action_just_pressed("Select Shotgun"):
			proxy_select_ind = 1
		if Input.is_action_just_released("Select Next"):
			proxy_select_next = true
		else:
			proxy_select_next = false
		if Input.is_action_just_released("Select Prev"):
			proxy_select_prev = true
		else:
			proxy_select_prev = false

		proxy_joy = Vector2(fake_axis("Strafe Right", "Strafe Left"), fake_axis("Forward", "Backwards"))
		player_movement_node.joy_input = proxy_joy.normalized()
		player_animation_node.joy_input = proxy_joy.normalized()

		$"../BodyCollision/LookHeight/LookDirection/GunController".in_fire = proxy_fire
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_fire_just_pressed = proxy_just_fired
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_alt_just_pressed = proxy_alt_fire_just_pressed
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_alt_just_released = proxy_alt_fire_just_released
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_select = proxy_select
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_select_ind = proxy_select_ind
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_select_next = proxy_select_next
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_select_prev = proxy_select_prev

		player_movement_node.run_input = proxy_run
		player_movement_node.crawl_input = proxy_crawl
		player_movement_node.jump_input = proxy_jump

	else:
		player_movement_node.joy_input = Vector2(0.0, 0.0)
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_fire = false
		$"../BodyCollision/LookHeight/LookDirection/GunController".in_fire_just_pressed = false
		player_movement_node.run_input = false
		player_movement_node.crawl_input = false
		player_movement_node.jump_input = false

func fake_axis(var positive, var negative):
	var ret = 0
	if Input.is_action_pressed(positive):
		ret += 1
	if Input.is_action_pressed(negative):
		ret -= 1
	return ret
