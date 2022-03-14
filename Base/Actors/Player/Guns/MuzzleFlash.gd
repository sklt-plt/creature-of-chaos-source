extends Spatial

func show():
	self.visible = true
	$"Timer".start()

func _on_Timer_timeout():
	self.visible = false
