extends Node
class_name PlayerStats

var s_level : int
var s_score : int
var s_time_total : float
var s_kills : int
var s_kills_possible : int
var s_shots_fired: int
var s_shots_hit: int
var s_treasure_open: int
var s_treasure_possible: int
var s_damage_dealt: int
var s_damage_taken: int
var s_deaths: int

func reset():
	#(re)set values to default
	s_level = 1
	s_score = 0
	s_time_total = 0
	s_kills = 0
	s_kills_possible = 0
	s_shots_fired = 0
	s_shots_hit = 0
	s_treasure_open = 0
	s_treasure_possible = 0
	s_damage_dealt = 0
	s_damage_taken = 0
	s_deaths = 0

func _process(delta):
	s_time_total += delta

func give(var stat, var value):
	#convert leveled score
	if stat == "s_leveled_score":
		stat = "s_score"
		value = value * s_level

	var stat_value = get(stat)

	if stat_value == null:
		print("Error: can't give stat '", stat, "' - not found")
		return

	set(stat, stat_value + value)

func check(var stat):
	var stat_value = get(stat)
	if stat_value == null:
		return 0
	else:
		return stat_value
