extends EnemyAI

func _init():
	ANIM_IDLE = "DummyIdle"
	ANIM_MOVE = "DummyWalk"
	ANIM_DIE = "DummyDie"
	ANIM_ATTACK_BEGIN = "DummyAttackBegin"
	ANIM_ATTACK_END = "DummyAttackEnd"
	ANIM_ATTACK_HOLD = "DummyAttackHold"
	ANIM_EXTRA = "DummyAttackExtra"

	health = 17
	movement_speed = 5
	awake_movement = AwakeMovementStates.MOVE_RANDOM
	combat_movement = CombatMovementStates.MOVE_CHARGE
	allow_chasing = true

	distance_to_melee = 4
	targeting_height_offset = 2.5
	projectile = load("res://Content/default/Actors/Enemies/Boomerangs/Boomerang.tscn")

	audio_callouts = []

	audio_death = load("res://Content/default/SFX/DummySfx.ogg")
	audio_attack_begin = load("res://Content/default/SFX/DummySfx.ogg")

	#gib_effect = load("path-to-gibs-tscn")

	kill_immediate_resources = {
		"r_time_freeze": 1.0,
		"s_kills": 1,
		"s_leveled_score": 100
	}

	get_parent().reduce_modifier_time = 0.067
