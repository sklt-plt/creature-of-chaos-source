extends StaticBody
class_name Hurtbox

signal deal_damage(damage, from_direction, from_ent)

func deal_damage(var damage, var from_direction, var from_ent):
	emit_signal("deal_damage", damage, from_direction, from_ent)
