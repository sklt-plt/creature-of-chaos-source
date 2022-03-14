extends Area

func _on_WaterVolume_body_entered(body):
	if body.has_method("on_water_entered"):
		body.on_water_entered()


func _on_WaterVolume_body_exited(body):
	if body.has_method("on_water_exited"):
		body.on_water_exited()
