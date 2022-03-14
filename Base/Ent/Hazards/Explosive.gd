extends Area
class_name Explosive

export (int) var expl_damage = 10

export (PackedScene) var effect

func explode(var to_ignore : Array = []):
	#add effect
	if effect != null:
		var n_effect = effect.instance()
		get_parent().add_child(n_effect)

	#deal damage indirectly in radius
	var in_blast = get_overlapping_bodies()

	#get physics space_state for raycasting
	var space_state = get_world().direct_space_state

	for body in in_blast:
		#check direct line of sight except for to_ignore (directly hit & missile parent)
		to_ignore.append(self)
		to_ignore.append(get_parent())
		to_ignore.append(get_node("../CollisionShape"))
		var result = space_state.intersect_ray(get_global_transform().origin, body.get_global_transform().origin, to_ignore, collision_mask)

		if result and result.collider == body:
			#how much of a fraction of damage to give to body
			var my_global_t = get_global_transform().origin
			var distance_to = my_global_t.distance_to(result.position)
			var mul
			if body == $"/root/Player":
				mul = 1/($BlastRadius.shape.radius + (distance_to - $BlastRadius.shape.radius))  # linear faloff
			else:
				 mul = 1

			if body.has_method("deal_damage"):
				body.deal_damage(expl_damage*mul, get_global_transform().origin , null)
				$"/root/Player".give("s_damage_dealt", expl_damage*mul)

	#remove explosive
	self.queue_free()
