extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("toggle_fullscreen"):
		if get_window().mode != Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
