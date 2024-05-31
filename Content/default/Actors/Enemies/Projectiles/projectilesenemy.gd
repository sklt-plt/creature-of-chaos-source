extends EnemyAI

func _init():
	ANIM_IDLE = "DummyIdle"
	ANIM_MOVE = "DummyWalk"
	ANIM_DIE = "DummyDie"
	ANIM_ATTACK_BEGIN = "DummyAttackBegin"
	ANIM_ATTACK_END = "DummyAttackEnd"

	health = 15.0
	movement_speed = 4.0
	combat_movement = 2

	targeting_height_offset = 0.8
	projectile = load("res://Content/default/Actors/Enemies/Projectiles/projectile.tscn")
	audio_callouts = [
		load("res://Content/default/SFX/DummySfx.ogg"),
		load("res://Content/default/SFX/DummySfx.ogg")]
	audio_death = load("res://Content/default/SFX/DummySfx.ogg")
	audio_attack_begin = load("res://Content/default/SFX/DummySfx.ogg")
	kill_immediate_resources = {
		"r_time_freeze": 1.0,
		"s_kills": 1,
		"s_leveled_score": 50
	}

	get_parent().reduce_modifier_time = 0.067
