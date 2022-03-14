extends Spatial
class_name ManualPlayerSpawn

func _ready():
	$"/root/Player".teleport(transform.origin, rotation_degrees.y)
