extends Node
class_name MusicController

var current_track_list = []

var music_player : AudioStreamPlayer
var music_player2 : AudioStreamPlayer
var current_music_player : AudioStreamPlayer

var current_track = -1
var looped = false

var crossfade_time = 0.0
const CROSSFADE_SPEED = 0.075

func _ready():
	music_player = $"../MusicPlayer"
	music_player2 = $"../MusicPlayer2"
	current_music_player = music_player

func play_next():
	if (current_track+1) == current_track_list.size():
		looped = true

	if current_track_list.empty():
		return

	current_track = (current_track+1)%current_track_list.size()
	current_music_player.stream = current_track_list[current_track]
	current_music_player.play()

func set_new_tracks_and_restart(var tracks_to_set: Array):
	current_track_list = tracks_to_set
	current_track = -1
	looped = false

func play_once_and_finish(var track: AudioStream):
	current_music_player.stream = track
	current_music_player.play()
	current_track_list.clear()
	current_music_player.disconnect("finished", self, "play_next")

func force_next_list(var new_tracks: Array):
	if not current_music_player.is_connected("finished", self, "play_next"):
		current_music_player.connect("finished", self, "play_next")

	set_new_tracks_and_restart(new_tracks)
	play_next()

func queue_next_list(var new_tracks: Array):
	#play new track list after current song finishes
	if not current_music_player.is_connected("finished", self, "play_next"):
		current_music_player.connect("finished", self, "play_next")

	set_new_tracks_and_restart(new_tracks)
	if not current_music_player.playing:
		play_next()

func crossfade_next_list(var new_tracks: Array):
	#fade out current song and fade in first song from new tracks
	#if no new_tracks are passed, just fade out and end playing
	set_new_tracks_and_restart(new_tracks)

	var old_music_player = current_music_player

	if old_music_player == music_player:
		current_music_player = music_player2
	else:
		current_music_player = music_player

	old_music_player.disconnect("finished", self, "play_next")
	current_music_player.connect("finished", self, "play_next")

	current_music_player.volume_db = linear2db(CROSSFADE_SPEED)
	play_next()
	var crossfade_time = CROSSFADE_SPEED

	while crossfade_time < 1.01:
		current_music_player.volume_db = linear2db(lerp(0.0, 1.0, crossfade_time))
		old_music_player.volume_db = linear2db(lerp(1.0, 0.0, crossfade_time))
		crossfade_time += CROSSFADE_SPEED
		yield(get_tree(), "physics_frame")

	current_music_player.volume_db = linear2db(1.0)
	old_music_player.stop()
