extends RigidBody

var exploded = false

func _enter_tree():
	mode = RigidBody.MODE_STATIC

func disable_collisions():
	var children = get_children()
	for c in children:
		if c is CollisionShape:
			c.disabled = true

func deal_damage(var _amount, var _from_dir, var _from_ent):
	if not exploded:
		exploded = true
		self.mode = MODE_STATIC
		disable_collisions()
		$Model.visible = false
		$AudioStreamPlayer3D.play()
		$Explosive.explode()
