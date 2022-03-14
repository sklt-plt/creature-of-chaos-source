extends Spatial

export (float) var health = 400.0

export (String) var hud_name = "boss name"
export (String) var anim_idle = ""
export (String) var anim_die = ""

export (AudioStream) var kill_track

var dead = false

export (Dictionary) var kill_immediate_resources = {
	"s_score" : 10000,
	"s_kills" : 1
}

func _ready():
	$Model/AnimationPlayer.play(anim_idle)
	$"/root/Player/HUD".register_boss_health(self, hud_name)
	$"/root/Player".give("s_kills_possible", 1)

func deal_damage(damage, _from_direction, _from_ent):
	if health > 0.1:
		health -= damage

	if health < 0.01 and not dead:
		dead = true
		$"/root/Player/HUD".deregister_boss_health()

		for r in kill_immediate_resources:
			$"/root/Player".give(r, kill_immediate_resources[r])

		$Model/AnimationPlayer.play(anim_die)
		var minions = get_tree().get_nodes_in_group("enemies")
		for m in minions:
			m.deal_damage(10000, Vector3.ZERO, null)

		var children = get_children()
		for c in children:
			if c is Drone:
				yield(get_tree().create_timer(0.1), "timeout")
				if is_instance_valid(c):
					c.destroy()

		$"/root/Player".play_slowmo_effect()
		$"/root/Player/MusicController".play_once_and_finish(kill_track)

		yield(get_tree().create_timer($"/root/Player/PlayerAnimations".SLOWMO_TOTAL_TIME), "timeout")
		$"/root/EpisodeManager".next_map()

func _on_Boss_tree_exiting():
	$"/root/Player/HUD".deregister_boss_health()
