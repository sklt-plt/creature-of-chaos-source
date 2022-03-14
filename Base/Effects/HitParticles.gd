extends Spatial

func _ready():
	var children = get_children()
	for c in children:
		if c is Particles:
			c.one_shot = true
			c.emitting = true

func _on_Timer_timeout():
	self.queue_free()
