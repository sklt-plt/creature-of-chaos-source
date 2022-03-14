extends Spatial

var children_cache = []

func _ready():
	children_cache = get_children()
	# don't want these in scene tree, just instances in array
	for c in children_cache:
		self.remove_child(c)
