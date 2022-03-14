extends Node

export (Array, DynamicFont) var font_resources

var font_default_sizes = []

func _ready():
	for f in font_resources:
		font_default_sizes.push_back(f.size)
