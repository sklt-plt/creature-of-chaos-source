extends Node
class_name InputHelper

static func set_input(var action : String, var event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
