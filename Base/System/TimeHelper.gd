extends Node
class_name TimeHelper

static func float_to_min_sec_msec_str(var input : float):
	var minutes = floor(input/60)
	var seconds = input-minutes*60
	return "%d:%02.2f" % [minutes, seconds]

static func float_to_min_sec_str(var input : float):
	var minutes = floor(input/60)
	var seconds = floor(input-minutes*60)
	return "%d:%02.f" % [minutes, seconds]
