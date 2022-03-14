extends Area

var colliders = []

const BASE_KINEMATIC_ACTOR_PUSH_FORCE = 10.0

func _physics_process(delta):
	for c in colliders:
		push_away(c, delta) # push

func push_away(var body: KinematicEnemy, var mul: float):
	var direction = (self.global_transform.origin - body.global_transform.origin) + (body.current_move_vector)
	#assumming parent is rigidbody
	get_parent().apply_impulse(Vector3(0.0, 0.25, 0.0), direction*BASE_KINEMATIC_ACTOR_PUSH_FORCE*mul)

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicEnemy and not colliders.has(body):
		push_away(body, 0.75) # kick
		colliders.push_back(body)

func _on_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicEnemy and colliders.has(body):
		colliders.erase(body)
