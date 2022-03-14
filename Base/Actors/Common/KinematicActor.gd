extends KinematicBody
class_name KinematicActor

var move_modifier_linear = Vector3(0,0,0)
var move_modifier_instant = Vector3(0,0,0)
var reduce_modifier_time = 0.3
var simulate_movement = true

func _physics_process(_delta):
		reduce_move_modifier()

func is_move_modif_neglible():
	return move_modifier_linear.length() == 0.0  #  < ??

func reduce_move_modifier():
	if not is_move_modif_neglible():
		move_modifier_linear = move_modifier_linear.linear_interpolate(Vector3(0,0,0), reduce_modifier_time)

func move_and_slide(var desired_move_vector, var floor_normal=Vector3( 0, 0, 0 ), var stop_on_slope=false, var max_slides=4, var floor_max_angle=0.785398, var infinite_inertia=true):
	if simulate_movement:
		if (move_modifier_instant != Vector3.ZERO):

			var ret = .move_and_slide(move_modifier_linear+move_modifier_instant+desired_move_vector, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)

			move_modifier_instant = Vector3.ZERO

			return ret
		else:
			return .move_and_slide(move_modifier_linear+desired_move_vector, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)


func push_linear(var force_origin, var force):
	if is_physics_processing():
		move_modifier_linear += (self.get_global_transform().origin-force_origin) *force

func push_instant(var from_direction):
	if is_physics_processing():
		move_modifier_instant -= from_direction
