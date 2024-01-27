extends Node


var p1_score: int:
	get: return _p1_score

var p2_score: int:
	get: return _p2_score


var _p1_score := 0
var _p2_score := 0


func reset() -> void:
	_p1_score = 0
	_p2_score = 0


func increment_p1_score() -> void:
	_p1_score += 1


func increment_p2_score() -> void:
	_p2_score += 1
