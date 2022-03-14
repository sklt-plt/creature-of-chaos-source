extends KinematicActor
class_name KinematicEnemy

enum AwakeMovementStates {
	IDLE,
	MOVE_RANDOM
}
enum CombatMovementStates {
	IDLE,
	MOVE_CHARGE,
	MOVE_RANDOM
}

enum States {
	DEAD,  # not processing
	IDLE,  # not processing
	AWAKE,
	MOVE_CHARGE,
	MOVE_CHASE,
	MOVE_RANDOM,
	ATTACK_MELEE,
	ATTACK_BEGIN,
	ATTACK_END,
	BOOMERANG_WAIT,
	BOOMERANG_CATCH
}

var ANIM_IDLE = "" # override these
var ANIM_MOVE = ""
var ANIM_DIE = ""
var ANIM_ATTACK_MELEE = ""
var ANIM_ATTACK_END = ""
var ANIM_ATTACK_BEGIN = ""
var ANIM_ATTACK_HOLD = ""
var ANIM_EXTRA = ""

export (float) var health = 50                   # how much damage enemy can take

export (float) var movement_speed = 8            # how fast it should move when engaging player
export (float) var movement_speed_wandering = 4  # how fast to move when not engaging player
export (float) var wander_single_time = 5.0      # for how long (seconds) to move in random direction when wandering / searching
												 # also applies to chasing

export (AwakeMovementStates) var awake_movement    # which movement to use when ai is awake but doesn't see the player
export (CombatMovementStates) var combat_movement  # which movement to use when ai sees the player

export (bool) var allow_chasing                  # should ai go towards last player's position when loses direct line of sight
												 # broken, if not going directly at player when it kicks in
export (bool) var uses_melee_attack              # allows performing melee attack (requires "melee" animation state machine node)
export (float) var melee_damage = 5              # how much damage to deal in MeleeArea (def 5)
export (float) var distance_to_melee = 10.0      # distance to player to perform melee (def 10.0)
export (float) var distance_to_melee_hit = 5.0   # distance to player to perform melee (def 10.0)

export (float) var targeting_height_offset          # how high above player cords to aim projectile (def 0.25)
export (float) var missile_spawn_z_offset           # how far ahead from spawner to spawn missile (def 2.0)
var missile_spawn_cords
export (PackedScene) var projectile              # if set, will try to perform ranged attack with this projectile scene

export (bool) var uses_raycast_attack            # unused yet

export (float) var los_check_y_offset = 2.5      # height offset for line-of-sight cheking

export (Array, AudioStream) var audio_callouts
export (AudioStream) var audio_death
export (AudioStream) var audio_attack

export (PackedScene) var gib_effect

export (bool) var is_dynamic = false				#allow de-spawning after death
export (bool) var DEBUG_set_awake = false

export (Dictionary) var kill_immediate_resources = {
	"s_leveled_score" : 100,
	"r_time_freeze" : 1.0,
	"s_kills" : 1
}

var current_wander_time = 0.0
var anim_player : AnimationPlayer
const wander_max_distance = 30.0
var wander_total_delta = 0.0
var current_state = States.IDLE
var last_player_pos
var visible_player = false
var last_simuated_pos
var current_move_vector = Vector3.ZERO

var audio_stream_player

var wander_timer : Timer
var ranged_attack_freq_timer : Timer
var ranged_attack_tele_timer : Timer
var audio_callouts_timer : Timer

func _ready():
	anim_player = $Model/AnimationPlayer
	audio_stream_player = $AudioStreamPlayer3D

	wander_timer = $WanderTimer
	ranged_attack_freq_timer = $RangedAttackFrequency
	ranged_attack_tele_timer = $RangedAttackTelegraph
	audio_callouts_timer = $AudioCalloutsTimer

	if projectile:
		missile_spawn_cords = get_node("MissileSpawnCords")

	if not audio_callouts.empty():
		$AudioCalloutsTimer.wait_time = audio_callouts[0].get_length() + 2.0 + rand_range(-0.75, 0.75)

	set_awake(DEBUG_set_awake)

	if not is_dynamic:
		$"/root/Player".give("s_kills_possible", 1)
		audio_stream_player.stream_paused = true
		simulate_movement = false
		$CollisionShape.disabled = true
		set_physics_process(false)
		self.visible = false
		$"/root/AIManager".register_ai(self)


func _physics_process(delta):
	if is_dynamic:
		_managed_process(delta)

	move_and_slide(current_move_vector, Vector3.ZERO, false, 4, 0.785398, false)
	._physics_process(delta)

func _managed_process(var delta):
	check_line_of_sight()

	update_current_state()

	process_current_state(delta)

func update_current_state():
	if health <= 0:
		begin_state(States.DEAD)

	if current_state == States.AWAKE:
		if (visible_player and is_player_in_range(distance_to_melee)
			and uses_melee_attack):
				ranged_attack_freq_timer.stop()
				begin_state(States.ATTACK_MELEE)
		elif (visible_player and (not is_player_in_range(distance_to_melee)
			or not uses_melee_attack)):

			if (projectile or uses_raycast_attack) and ranged_attack_freq_timer.is_stopped():
				ranged_attack_freq_timer.start()
			begin_state(get_combat_movement())

		elif not visible_player and last_player_pos and allow_chasing:
			ranged_attack_freq_timer.stop()
			begin_state(States.MOVE_CHASE)
		else:
			ranged_attack_freq_timer.stop()
			if (awake_movement == AwakeMovementStates.IDLE):
				play_animation(ANIM_IDLE)
				current_move_vector = Vector3.ZERO
			begin_state(get_awake_movement())

func process_current_state(var delta):
	match current_state:
		States.DEAD:
			if .is_move_modif_neglible():
				set_physics_process(false)
				$CollisionShape.disabled = true
			simulate_movement = false

		States.ATTACK_MELEE:
			if anim_player.current_animation != ANIM_ATTACK_MELEE: # ughhhhh
				begin_state(States.AWAKE)
				return

			# player should detect collision themselves

			if not is_at_target(last_player_pos):
				face_target(last_player_pos)
			current_move_vector = transform.basis.xform(Vector3(0,-1,-1))* movement_speed

		States.ATTACK_BEGIN:
			current_move_vector = Vector3.ZERO
			face_target(last_player_pos)

		States.MOVE_CHARGE:
			if visible_player and not is_player_in_range(distance_to_melee):
				face_target(last_player_pos)
				current_move_vector = transform.basis.xform(Vector3(0,-1,-1))* movement_speed
			else:
				begin_state(States.AWAKE)
				current_move_vector = Vector3.ZERO

		States.MOVE_CHASE:
			if not visible_player and wander_total_delta < wander_single_time:
				wander_total_delta += delta
				current_move_vector = transform.basis.xform(Vector3(0,-1,-1))* movement_speed
			else:
				visible_player = false
				begin_state(States.AWAKE)
				current_move_vector = Vector3.ZERO

		States.BOOMERANG_CATCH:
			current_move_vector = Vector3.ZERO
			if anim_player.current_animation != ANIM_EXTRA:
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				begin_state(States.AWAKE)

		States.ATTACK_END:
			current_move_vector = Vector3.ZERO
			if anim_player.current_animation != ANIM_ATTACK_END:
				var p = projectile.instance()
				if p is Boomerang:
					begin_state(States.BOOMERANG_WAIT)
				else:
					if not audio_callouts.empty():
						audio_callouts_timer.start()
					begin_state(States.AWAKE)

		States.MOVE_RANDOM:
			if ((visible_player and combat_movement != CombatMovementStates.MOVE_RANDOM)
				or (!visible_player and last_player_pos and allow_chasing)):
				wander_timer.stop()
				begin_state(States.AWAKE)
				return

			current_move_vector = transform.basis.xform(Vector3(0,-1,-1))* movement_speed_wandering

func begin_state(var desired_state):
	if desired_state != current_state:
		match desired_state:
			States.DEAD:
				current_state = States.DEAD
				simulate_movement = false
				wander_timer.stop()
				ranged_attack_tele_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_callouts_timer.stop()
				.get_node("CollisionShape").disabled = true
				if ANIM_DIE != "":
					play_animation(ANIM_DIE)
				elif gib_effect:
					get_node("Model").visible = false
					self.add_child(gib_effect.instance())
				play_audio(audio_death)

				if (is_dynamic):
					yield(get_tree().create_timer(3.0, false), "timeout")
					queue_free()
				else:
					#don't give score for respawning enemies
					for r in kill_immediate_resources:
						$"/root/Player".give(r, kill_immediate_resources[r])
			States.AWAKE:
				self.visible = true
				play_animation(ANIM_IDLE)
				$CollisionShape.disabled = false
				set_physics_process(true)
				simulate_movement = true
				if not last_simuated_pos:
					last_simuated_pos = translation
				audio_stream_player.stream_paused = false
				audio_callouts_timer.start()
				current_state = States.AWAKE
			States.MOVE_CHASE:
				reset_delta_search()
				face_target(last_player_pos)
				current_state = States.MOVE_CHASE
			States.MOVE_CHARGE:
				play_animation(ANIM_MOVE)
				current_state = States.MOVE_CHARGE
			States.ATTACK_MELEE:
				play_audio(audio_attack)
				play_animation(ANIM_ATTACK_MELEE)
				current_state = States.ATTACK_MELEE
			States.ATTACK_BEGIN:
				audio_callouts_timer.stop()
				play_audio(audio_attack)
				play_animation(ANIM_ATTACK_BEGIN)
				ranged_attack_freq_timer.stop()
				ranged_attack_tele_timer.start()
				current_state = States.ATTACK_BEGIN
			States.ATTACK_END:
				play_animation(ANIM_ATTACK_END)
				current_state = States.ATTACK_END
			States.MOVE_RANDOM:
				play_animation(ANIM_MOVE)
				visible_player = false
				wander_timer.start(rand_range(wander_single_time/2.0, wander_single_time))
				face_target(find_random_point_to_wander_to())
				current_state = States.MOVE_RANDOM
			States.BOOMERANG_WAIT:
				wander_timer.stop()
				play_animation(ANIM_ATTACK_HOLD)
				current_state = States.BOOMERANG_WAIT
			States.BOOMERANG_CATCH:
				play_animation(ANIM_EXTRA)
				current_state = States.BOOMERANG_CATCH
			States.IDLE:
				self.visible = false
				set_physics_process(false)
				$CollisionShape.disabled = true
				teleport_to_spawn()
				simulate_movement = false
				wander_timer.stop()
				audio_callouts_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_stream_player.stream_paused = true
				current_state = States.IDLE
			_:
				print("Unknown state: ", desired_state)

func teleport_to_spawn():
	if last_simuated_pos:
		translation = last_simuated_pos
		last_simuated_pos = null

func get_combat_movement():
	match combat_movement:
		CombatMovementStates.MOVE_CHARGE:
			return States.MOVE_CHARGE
		CombatMovementStates.MOVE_RANDOM:
			return States.MOVE_RANDOM
		CombatMovementStates.IDLE:
			return States.AWAKE

func get_awake_movement():
	match awake_movement:
		AwakeMovementStates.MOVE_RANDOM:
			return States.MOVE_RANDOM
		AwakeMovementStates.IDLE:
			return States.AWAKE

func face_target(var target):
	if target:
		var new_target = Vector3()
		new_target = target
		new_target.y = self.get_global_transform().origin.y

		look_at(new_target, Vector3.UP)

func deal_damage(var damage, var from_direction, var from_ent):
	if .is_physics_processing() and current_state == States.AWAKE:
		if from_ent and not visible_player:
			visible_player = true
		begin_state(States.AWAKE)

	health -= damage
	.push_linear(from_direction, damage/2)

func reset_delta_search():
	wander_total_delta = 0

func is_at_target(var target: Vector3):
	return is_in_range(target, 1.0)

func is_in_range(var target: Vector3, var distance):
	var to_target = Vector3(target.x, get_global_transform().origin.y, target.z) - get_global_transform().origin
	return (to_target.length() < distance)

func is_player_in_range(var distance):
	var target_pos = $"/root/Player".get_global_transform().origin
	return is_in_range(target_pos, distance)

func find_random_point_to_wander_to():
	var new_target = Vector3()
	new_target.x = get_global_transform().origin.x + rand_range(-wander_max_distance, wander_max_distance)
	new_target.z = get_global_transform().origin.z + rand_range(-wander_max_distance, wander_max_distance)
	return new_target

func set_awake(var awake):
	if current_state != States.DEAD:
		if awake:
			begin_state(States.AWAKE)
		else:
			begin_state(States.IDLE)

func _on_WanderTimer_timeout():
	if current_state == States.MOVE_RANDOM:
		begin_state(States.AWAKE)

func check_line_of_sight():
	if current_state >= States.AWAKE:
		var player_node = $"/root/Player"

		#do a raycast
		var space_state = get_world().direct_space_state
		var origin = get_global_transform().origin
		origin.y += los_check_y_offset
		var target = player_node.get_global_transform().origin + Vector3(0, los_check_y_offset, 0)

		var ray_result = space_state.intersect_ray(origin, target, [get_parent()], collision_mask)
		if ray_result and ray_result.collider == player_node:

			if not player_node.is_dead():
				visible_player = true

			elif player_node.is_dead():
				visible_player = false

		else:
			visible_player = false

	if visible_player:
		last_player_pos = $"/root/Player".get_global_transform().origin

func _on_RangedAttackFrequency_timeout():
	if current_state >= States.AWAKE:
		begin_state(States.ATTACK_BEGIN)

func _on_RangedAttackTelegraph_timeout():
	if current_state == States.ATTACK_BEGIN:
		if projectile:
			var pos = missile_spawn_cords.get_global_transform().translated(
				Vector3(0,0,-missile_spawn_z_offset)).origin

			var p = ProjectileSpawnHelper.spawn_projectile(projectile, get_parent(), pos,
				last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))

			if p is Boomerang:
				p.look_at(Vector3(last_player_pos.x, p.get_global_transform().origin.y, last_player_pos.z), Vector3.UP)
				p.target = Vector3(last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))
				p.boomerang_owner = self

			begin_state(States.ATTACK_END)

func _on_returned_boomerang():
	if current_state != States.DEAD:
		begin_state(States.BOOMERANG_CATCH)

func play_animation(var animation_name: String):
	if animation_name != "":
		anim_player.play(animation_name)
		if anim_player.current_animation != animation_name:
			print("Error playing: ", animation_name)

func play_audio(var audio : AudioStream):
	if current_state != States.IDLE:
		audio_stream_player.stream = audio
		audio_stream_player.play()

func _on_AudioCalloutsTimer_timeout():
	#play random callout
	if not audio_stream_player.playing:
		play_audio(audio_callouts[randi()%audio_callouts.size()])
