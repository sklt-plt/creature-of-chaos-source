extends KinematicActor
class_name PlayerInterface

func on_water_entered():
	$PlayerMovement.enteredWater()

func on_water_exited():
	$PlayerMovement.exitedWater()

func start_flying():
	$PlayerMovement.start_flying()

func stop_flying():
	$PlayerMovement.stop_flying()

func on_ladder_entered(var ladderPos):
	$PlayerMovement.enteredLadder(ladderPos)

func on_ladder_exited():
	$PlayerMovement.exitedLadder()

func save():
	return $PlayerState.save()

func revive():
	var pr = $"PlayerResources"
	pr.r_health = pr.resources_limits["r_health"]/2
	pr.r_armor = pr.resources_limits["r_armor"]/5
	pr.r_pistol_ammo = pr.resources_limits["r_pistol_ammo"]/2
	pr.r_shotgun_ammo = pr.resources_limits["r_shotgun_ammo"]/2
	$"PlayerStats".give("s_deaths", 1)
	$"PlayerStats".give("s_score", -10000)
	$"HUD/HurtEffect".color.a = 0.5		#stylistic choice, set 0.0 to clear
	enable()

func reset():
	$"HUD/HurtEffect".color.a = 0.0
	$"HUD/Arcade".visible = false
	$"PlayerResources".reset()
	$"PlayerStats".reset()
	$BodyCollision/LookHeight/LookDirection/GunController.switch_guns(0, false)
	$"GameOverStats".reset()
	enable()

func enable():
	self.visible = true
	$"PlayerMovement".is_dead = false
	$"InputProxy".is_locked = false
	$"SFXPlayer".stop()
	$"SFXPlayer2".stop()
	$"SFXPlayer3".stop()

func deal_damage(var damage, var from_direction, var _from_ent):
	$"PlayerResources".deal_damage(damage)
	$"PlayerStats".give("s_damage_taken", damage)
	.push_linear(from_direction, damage)

func upgrade_resource(var resource, var value):
	$"PlayerResources".upgrade_resource(resource, value)

func give(var property : String, var value):
	if property.begins_with("s_"):
		$"PlayerStats".give(property, value)
	else:
		return $"PlayerResources".give(property, value)

func take(var property, var value):
	return $"PlayerResources".take(property, value)

func has(var property, var value):
	return $"PlayerResources".has(property, value)

func check(var property):
	if property.begins_with("s_"):
		return $"PlayerStats".check(property)
	else:
		return $"PlayerResources".check(property)

func check_limit(var property):
	return $"PlayerResources".check_limit(property)

func set(var property, var value):
	if property == "is_locked":
		$"InputProxy".is_locked = value

	elif property.begins_with("r_") or property.begins_with("e_"):
		$"PlayerResources".set(property, value)
	else:
		.set(property, value)

func teleport(var pos : Vector3, var rot : float):
	transform.origin = pos
	rotation_degrees.y = rot

func refresh_shaders():
	$"BodyCollision/LookHeight/LookDirection/WorldCamera".flash_cache_objects()

func show_loading():
	$"FakeLoading".visible = true

func hide_loading():
	$"FakeLoading".visible = false

func is_dead():
	return $"PlayerResources".r_health <= 0.0

func _ready():
	$"/root/Initializer".on_player_ready()

func set_fov(var fov : float):
	$"BodyCollision/LookHeight/LookDirection/WorldCamera".fov = fov

func start_arcade_mode():
	$"PlayerResources".use_time_limit = true
	$"HUD/Arcade".visible = true

func play_slowmo_effect():
	$"PlayerAnimations".play_slowmo()
