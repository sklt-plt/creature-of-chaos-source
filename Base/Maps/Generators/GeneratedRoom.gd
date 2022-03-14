extends Spatial
class_name GeneratedRoom

enum ROOM_TRAITS {
	##GENERATORS
	STARTING,
	MAIN,
	END_MAIN,
	SUB,
	END_SUB,
	NORMAL_CORRIDORS,
	ARENA,
	##OBJECTS
	KEY,
	TREASURE,
	KEY_AND_TREASURE,
	#TRAPPED_TREASURE,
	LOCKED_DOOR,
	EXIT_DOOR
}

export (NodePath) var geometry

var size

var difficulty : float

var prefab_room

export (Array, ROOM_TRAITS) var traits
