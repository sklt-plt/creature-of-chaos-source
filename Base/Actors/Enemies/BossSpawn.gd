extends Spatial
tool

export (PackedScene) var boss_scene

func _ready():
	var instance = boss_scene.instance() as Spatial

	get_parent().get_parent().add_child(instance)
	instance.owner = get_parent().get_parent().owner

	var room_geometry = get_parent()

	instance.global_transform.origin = room_geometry.global_transform.origin + Vector3((room_geometry.size.x/2), 0, (room_geometry.size.z/2))

	#find entrance to rotate instance towards to
	var exits = room_geometry.used_exits()
	var dir = -1

	for e in exits:
		if e["target"] == get_node(room_geometry.tree_ref).get_parent().geometry:
			dir = e["direction"]

	if dir == -1:
		return

	match dir:
		0:
			instance.translate_object_local(Vector3(0,0,room_geometry.size.z/2))
		1:
			instance.rotation_degrees.y += 180
			instance.translate_object_local(Vector3(0,0,room_geometry.size.z/2))
		2:
			instance.rotation_degrees.y += 90
			instance.translate_object_local(Vector3(0,0,room_geometry.size.x/2))
		3:
			instance.rotation_degrees.y -= 90
			instance.translate_object_local(Vector3(0,0,room_geometry.size.x/2))

	instance.scale = Vector3(24,24,24)

