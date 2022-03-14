extends StaticBody

func deal_damage(var _amount, var _direction, var source_node):
	if source_node == $"/root/Player":
		$CollisionShape.disabled = true
		get_parent().activate()
