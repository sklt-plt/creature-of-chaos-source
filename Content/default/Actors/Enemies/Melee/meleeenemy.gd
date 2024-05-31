extends EnemyAI

func _init():
	ANIM_IDLE = "DummyIdle"
	ANIM_MOVE = "DummyWalk"
	ANIM_ATTACK_MELEE = ["DummyAttackMelee"]
	ANIM_DIE = "DummyDie"

	health = 20
	combat_movement = 1
	direct_damage = 30.0
	allow_chasing = true
	uses_melee_attack = true
	audio_callouts = []
	audio_death = load("res://Content/default/SFX/DummySfx.ogg")

	kill_immediate_resources = {
		"r_time_freeze": 1.0,
		"s_kills": 1,
		"s_leveled_score": 150
	}
