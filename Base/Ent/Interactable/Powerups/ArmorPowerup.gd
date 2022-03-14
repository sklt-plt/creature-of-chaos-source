extends BasePowerup

func activate():
	.activate()
	$"/root/Player".upgrade_resource("r_armor", 5)
	.playSfx()
	self.queue_free()
