extends BasePowerup

func activate():
	.activate()
	$"/root/Player".give("e_double_barrel_level", 1)
	$"/root/Player".give("r_shotgun_ammo", 15)

	.playSfx()

	self.queue_free()
