extends Skeleton

signal deal_damage(damage, from_direction, from_ent)

func _ready():
	# connect all hurtboxes
	var skeleton_children = get_children()
	for skeleton_child in skeleton_children:
		if skeleton_child is BoneAttachment:
			var bone_children = skeleton_child.get_children()
			for bone_child in bone_children:
				if bone_child is Hurtbox:
					bone_child.connect("deal_damage", self, "deal_damage", [])

func deal_damage(var damage, var from_direction, var from_ent):
	emit_signal("deal_damage", damage, from_direction, from_ent)
