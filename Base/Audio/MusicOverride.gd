extends Node
class_name MusicOverride

enum TRANSITION_TYPE {
	CROSSFADE,
	QUEUE,
	INSTANT
}

export (TRANSITION_TYPE) var transition_type

export (Array, AudioStream) var new_tracks

func _ready():
	match transition_type:
		TRANSITION_TYPE.QUEUE:
			$"/root/Player/MusicController".queue_next_list(new_tracks)
		TRANSITION_TYPE.CROSSFADE:
			$"/root/Player/MusicController".crossfade_next_list(new_tracks)
		TRANSITION_TYPE.INSTANT:
			$"/root/Player/MusicController".force_next_list(new_tracks)
