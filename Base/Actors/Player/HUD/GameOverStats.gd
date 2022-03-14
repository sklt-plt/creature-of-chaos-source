extends GameOver

var reason = "You Died"
var stats_labels

func _ready():
	stats_labels = $"StatsSC/GC".get_children()

func reset():
	reason = "You Died"
	$"Control/RestartB".visible = true
	$"Control/QuitB".text = "Quit"

func _on_RestartB_button_up():
	hide()
	$"/root/Player".reset()
	$"/root/EpisodeManager".restart_episode()

func show():
	$"DelayT".stop()
	.show()

	$"Label".text = reason

	var player = $"/root/Player"

	if $"/root/EpisodeManager".is_endless_episode_playing():
		$"StatsSC/GC/LevelL".visible = true
		$"StatsSC/GC/LevelVal".visible = true
		$"StatsSC/GC/LevelVal".text = String(player.check("s_level"))
	else:
		$"StatsSC/GC/LevelL".visible = false
		$"StatsSC/GC/LevelVal".visible = false

	$"StatsSC/GC/TimeVal".text = TimeHelper.float_to_min_sec_msec_str(player.check("s_time_total"))

	var kills = player.check("s_kills")
	var kills_possible = player.check("s_kills_possible")
	var kills_text = String(kills) + " out of " + String(kills_possible)

	$"StatsSC/GC/KillsVal".text = kills_text
	if kills_possible > 0:
		$"StatsSC/GC/KillsPVal".text = String(kills*100 / kills_possible) + " %"

	var shots_hit = player.check("s_shots_hit")
	var shots_total = player.check("s_shots_fired")
	var shots_text = String(shots_hit) + " out of " + String(shots_total)

	$"StatsSC/GC/ShotsHVal".text = shots_text
	if shots_total > 0:
		$"StatsSC/GC/AccuracyVal".text = String((shots_hit*100 / shots_total)) + " %"
	else:
		$"StatsSC/GC/AccuracyVal".text = "0 %"

	var treasure = player.check("s_treasure_open")
	var treasure_possible = player.check("s_treasure_possible")
	var treasure_text = String(treasure) + " out of " + String(treasure_possible)

	$"StatsSC/GC/TreasVal".text = treasure_text

	$"StatsSC/GC/DamageDVal".text = String(player.check("s_damage_dealt"))
	$"StatsSC/GC/DamageTVal".text = String(player.check("s_damage_taken"))

	if $"/root/EpisodeManager".is_normal_episode_playing():
		$"Label".text = "Episode Complete!"
		$"Control/RestartB".visible = false
		$"Control/QuitB".text = "Continue"
		$"StatsSC/GC/DeathsVal".text = String(player.check("s_deaths"))
		$"StatsSC/GC/DeathsVal".visible = true
		$"StatsSC/GC/DeathsL".visible = true
	else:
		$"StatsSC/GC/DeathsVal".visible = false
		$"StatsSC/GC/DeathsL".visible = false

	$"StatsSC/GC/ScoreVal".text = String(player.check("s_score"))
