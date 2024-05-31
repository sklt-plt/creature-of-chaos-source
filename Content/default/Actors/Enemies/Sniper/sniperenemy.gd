extends EnemyAI

func _init():
	ANIM_IDLE = "DummyIdle"
	ANIM_MOVE = "DummyWalk"
	ANIM_DIE = "DummyDie"
	ANIM_ATTACK_BEGIN = "DummyAttackBegin"
	ANIM_ATTACK_END = "DummyAttackEnd"
	ANIM_ATTACK_HOLD = ""
	ANIM_EXTRA = ""

	health = 8
	movement_speed = 5.0
	allow_chasing = true
	direct_damage = 20.0
	targeting_height_offset = 2.5
	uses_raycast_attack = true
	allow_attack_cancelling = true
	los_check_player_height = 2.011

	audio_callouts = [
		load("res://Content/default/SFX/DummySfx.ogg")
	]

	audio_death = load("res://Content/default/SFX/DummySfx.ogg")
	audio_attack_begin = load("res://Content/default/SFX/DummySfx.ogg")

	#gib_effect = load("path-to-gibs-tscn")

	kill_immediate_resources = {
		"r_time_freeze": 1.0,
		"s_kills": 1,
		"s_leveled_score": 100
	}
