extends Node


signal level_timeout


@export var level_time := 180


@onready var _time_label: Label = $CanvasLayer/TimeLabel
@onready var _timer: Timer = $Timer


@onready var _remaining_time := level_time


func _ready() -> void:
	_time_label.text = _format_time()


func _on_timer_timeout() -> void:
	_remaining_time -= 1
	_time_label.text = _format_time()
	if _remaining_time == 0:
		_timer.stop()
		level_timeout.emit()


func _format_time() -> String:
	return "%d:%02d" % [ _remaining_time / 60, _remaining_time % 60 ]
