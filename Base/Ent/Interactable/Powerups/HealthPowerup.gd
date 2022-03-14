extends BasePowerup

func activate():
	.activate()
	$"/root/Player".upgrade_resource("r_health", 5)
	.playSfx()
	self.queue_free()
