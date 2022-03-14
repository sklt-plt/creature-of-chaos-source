extends Node
class_name ProjectileSpawnHelper

static func spawn_projectile(
	var projectile_scene: PackedScene, 
	var parent : Node, 
	var start_pos : Vector3, 
	var target_pos : Vector3):
		
		var p = projectile_scene.instance()

		#fire projectile
		parent.add_child(p)
		p.global_transform.origin = start_pos

		p.look_at(target_pos, Vector3.UP)
		
		return p
