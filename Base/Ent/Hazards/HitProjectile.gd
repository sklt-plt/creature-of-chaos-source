extends BaseProjectile
class_name HitProjectile

export var projectile_damage = 20.0

func hit_target(var col):
	if col.collider.has_method("deal_damage"):
		col.collider.deal_damage(projectile_damage*1, .get_global_transform().origin , null)

		var explosive = .get_node_or_null("Explosive")
		if explosive:
			explosive.explode([self, col.collider])

		return true
	return false

func deal_damage(var _amount, var _direction, var _from_node):
	var explosive = .get_node_or_null("Explosive")
	if explosive:
		explosive.explode([self])
	queue_free()

func _on_DecayTimer_timeout():
	var explosive = .get_node_or_null("Explosive")
	if explosive:
		explosive.explode([self])

	.queue_free()
