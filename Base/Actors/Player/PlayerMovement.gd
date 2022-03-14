extends Node
class_name PlayerMovement

export (float) var walk_speed = 7.5  #max walking speed
export (float) var walk_aim_speed = 5.5  #max walking speed
export (float) var run_speed = 17  #max running speed
export (float) var accel = 0.2  #(de)acceleration in x and z axes
export (float) var jump_power = 15  #initial y magnitude during jump
export (float) var gravity = 0.01  #(de)acceleration in y axis
export (float) var max_fall_speed = -80  # vertical (downward) terminal velocity

export (float) var water_speed = 4  #max speed in water
export (float) var water_sink_speed = 4  #max fall speed in water
export (float) var water_gravity = 0.05  #(de)acceleration in y axis in water when not moving

export (float) var fly_speed = 30  #max speed while flying (debug)

export (float) var crawl_speed = 2
export (float) var to_crawl_lerp = 0.15

var mouse_sensitivity = 0.225

var kinematic_body_node : KinematicBody
var gun_controller_node : GunController

var joy_input = Vector2()
var jump_input = false
var crawl_input = false
var run_input = false

var current_movement = Vector3(0,0,0)
var is_crawling = false
var crawl_coroutine
var crawl_x = 0.0
var current_crawl_speed = 0.0
var is_dead = false

var oryginal_height
var oryginal_camera_height

var in_water
var on_ladder
var ladderPos
var ladderEnterPos
var is_flying

func _ready():
	kinematic_body_node = get_parent()
	gun_controller_node = $"../BodyCollision/LookHeight/LookDirection/GunController"

	oryginal_height = $"../BodyCollision".shape.height
	oryginal_camera_height = $"../BodyCollision/LookHeight".translation.z

	set_physics_process(true);

	crawl_coroutine = crawl()

func _physics_process(_delta):
	move(joy_input.x, joy_input.y)

func get_desired_speed():
	if in_water:
		return water_speed

	if is_flying:
		return fly_speed

	if is_crawling:
		return current_crawl_speed

	if gun_controller_node.current_gun.in_aim_mode:
		return walk_aim_speed

	if (not $"/root/Globals".user_settings["invert_run"] and run_input
		|| $"/root/Globals".user_settings["invert_run"] and not run_input):
		return run_speed

	return walk_speed

func get_desired_fall_speed():
	if in_water:
		return -water_sink_speed

	if on_ladder or is_flying:
		return 0.0

	else: return max_fall_speed

func get_desired_gravity():
	if in_water:
		return water_gravity

	if on_ladder or is_flying:
		return 0.9

	else: return gravity


func crawl():
	while(true):
		if (crawl_input && kinematic_body_node.is_on_floor() && not is_crawling && not in_water && not is_flying) or is_dead:
			is_crawling = true
			current_crawl_speed = walk_speed

			while (crawl_input or is_dead):
				if (crawl_x < 1.62):
					crawl_x += to_crawl_lerp

				if is_dead:
					$"../BodyCollision".shape.height = oryginal_height - sin(crawl_x)*2
					$"../BodyCollision/LookHeight".translation.z = oryginal_camera_height + sin(crawl_x)*1.4
				else:
					$"../BodyCollision".shape.height = oryginal_height - sin(crawl_x)
					$"../BodyCollision/LookHeight".translation.z = oryginal_camera_height + sin(crawl_x)

				current_crawl_speed  = lerp(current_crawl_speed, crawl_speed, to_crawl_lerp/2)

				yield(get_tree(), "idle_frame")


			while (crawl_x > 0):
				crawl_x -= to_crawl_lerp

				current_crawl_speed = lerp(current_crawl_speed, walk_speed, to_crawl_lerp/2)
				$"../BodyCollision".shape.height = oryginal_height - sin(crawl_x)
				$"../BodyCollision/LookHeight".translation.z = oryginal_camera_height + sin(crawl_x)

				yield(get_tree(), "idle_frame")


			current_crawl_speed = walk_speed
			$"../BodyCollision".shape.height = oryginal_height
			$"../BodyCollision/LookHeight".translation.z = oryginal_camera_height

			is_crawling = false
			crawl_x = 0.0

		yield(get_tree(), "idle_frame")


func move(var horizontal_input, var vertical_input):
	#get desired movement model
	var desired = {
		"speed"   : get_desired_speed(),
		"fall_speed" : get_desired_fall_speed(),
		"gravity"    : get_desired_gravity()
	}

	#lerp to new motion
	if in_water or on_ladder or is_flying:
		var rotx = deg2rad($"../BodyCollision/LookHeight/LookDirection".rotation_degrees.x)

		if in_water or is_flying:
			current_movement.x = lerp(current_movement.x, horizontal_input*desired["speed"], accel)
			current_movement.z = lerp(current_movement.z, -vertical_input*desired["speed"]*cos(rotx), accel)
		else:
			current_movement.x = 0.0
			current_movement.z = 0.0
			kinematic_body_node.translation.x = lerp(ladderEnterPos.x, ladderPos.x, accel)
			kinematic_body_node.translation.z = lerp(ladderEnterPos.z, ladderPos.y, accel)
			ladderEnterPos = kinematic_body_node.translation


		if abs(horizontal_input) > 0.01 or abs(vertical_input) > 0.01:
			current_movement.y = lerp(current_movement.y, vertical_input*desired["speed"]*sin(rotx), accel)
		else:
			current_movement.y = lerp(current_movement.y, desired["fall_speed"], desired["gravity"])

	else:
		current_movement.x = lerp(current_movement.x, horizontal_input*desired["speed"], accel)
		current_movement.z = lerp(current_movement.z, -vertical_input*desired["speed"], accel)
		current_movement.y = lerp(current_movement.y, desired["fall_speed"], desired["gravity"])

	#override fall motion
	if kinematic_body_node.is_on_floor() and not (in_water or is_flying):
		if jump_input && !is_crawling:
			current_movement.y = jump_power
		else:
			current_movement.y = 0.0

	if (in_water or is_flying) and jump_input:
		current_movement.y = lerp(current_movement.y, desired["speed"], accel)
	if (in_water or is_flying) and crawl_input:
		current_movement.y = lerp(current_movement.y, -desired["speed"], accel)

	if on_ladder and jump_input:
		exitedLadder()
		current_movement.y = jump_power


	#transform along camera
	var move_vec = Vector3()
	move_vec += kinematic_body_node.transform.basis.z.normalized() * current_movement.z
	move_vec += kinematic_body_node.transform.basis.x.normalized() * current_movement.x
	move_vec += kinematic_body_node.transform.basis.y.normalized() * current_movement.y

	kinematic_body_node.move_and_slide(move_vec, Vector3(0,1,0))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$"../BodyCollision/LookHeight/LookDirection".rotate_x(deg2rad(event.relative.y * mouse_sensitivity *-1))

		$"../BodyCollision/LookHeight/LookDirection".rotation_degrees.x = clamp($"../BodyCollision/LookHeight/LookDirection".rotation_degrees.x, -90, 90)

		kinematic_body_node.rotate_y(deg2rad(event.relative.x * mouse_sensitivity *-1))

func set_dead():
	exitedLadder()
	is_dead = true

func enteredWater():
	in_water = true

func exitedWater():
	in_water = false

func start_flying():
	is_flying = true

func stop_flying():
	is_flying = false

func enteredLadder(var where):
	on_ladder = true
	in_water = false
	ladderEnterPos = kinematic_body_node.translation
	ladderPos = where

func exitedLadder():
	on_ladder = false
