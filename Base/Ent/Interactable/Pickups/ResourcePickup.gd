extends Spatial
class_name ResourcePickup

export (bool) var respawns = false
export (Dictionary) var contents = {}
export (AudioStream) var audio_effect

const ARCADE_TIME_BONUS = 0.25

func on_body_entered(body):
	if self.visible and body.is_in_group("PlayerTeam"):
		if $"/root/EpisodeManager".is_endless_episode_playing():
			contents["r_time_freeze"] = ARCADE_TIME_BONUS

		var given_any_contents = false
		for res in contents:
			if $"/root/Player".give(res, contents[res]):
				given_any_contents = true

		if given_any_contents:
			self.hide()

			$"/root/Player/SFXPlayer".stream = audio_effect
			$"/root/Player/SFXPlayer".play()

			if respawns:
				$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	self.show()

func set(var property, var value):
	if (respawns and !visible and property == "time_left"):
		$RespawnTimer.start(value)
	else:
		.set(property, value)
