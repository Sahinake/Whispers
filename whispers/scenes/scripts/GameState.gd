extends Node

var skip_intro := false
var deposited_runes := 0
var altar_activated := false
var collected_runes := {}  # id -> true
var collected_algae := {}  # id -> true
var last_level_name := ""  # guarda o level anterior

func reset_game_state():
	deposited_runes = 0
	altar_activated = false
	collected_runes.clear()
	collected_algae.clear()
