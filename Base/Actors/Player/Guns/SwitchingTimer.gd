extends Timer

signal finish_switching(idx)

var switching_idx = -1

func _on_SwitchingTimer_timeout():
	emit_signal("finish_switching", switching_idx)
