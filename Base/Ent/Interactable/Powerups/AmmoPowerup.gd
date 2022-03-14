extends BasePowerup

func activate():
	.activate()
	$"/root/Player".upgrade_resource("ammo_bonus_cap", 5)

	$"/root/Player".give("r_pistol_ammo", 5)
	$"/root/Player".give("r_shotgun_ammo", 5)

	.playSfx()

	self.queue_free()
