extends Spatial

func _on_ladderVolume_body_entered(body):
	if body.has_method("on_ladder_entered"):
		body.on_ladder_entered(Vector2(translation.x, translation.z))

func _on_ladderVolume_body_exited(body):
	if body.has_method("on_ladder_exited"):
		body.on_ladder_exited()
