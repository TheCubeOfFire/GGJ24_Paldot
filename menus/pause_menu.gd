extends Control


@export_file var main_menu_scene_path: String


@onready var _resume_button: Button = %ResumeButton


func _input(event: InputEvent) -> void:
	if event.is_action_released("toggle_pause"):
		_set_pause(not get_tree().paused)


func _set_pause(paused: bool) -> void:
	if get_tree().paused:
		visible = false
		var volume_tween := MusicManager.create_tween()
		volume_tween.tween_property(MusicManager, "volume_db", 0.0, 0.2)
	else:
		visible = true
		var volume_tween := MusicManager.create_tween()
		volume_tween.tween_property(MusicManager, "volume_db", -10.0, 0.2)
		_resume_button.grab_focus()

	get_tree().paused = paused


func _on_resume_button_pressed() -> void:
	_set_pause(false)


func _on_quit_button_pressed() -> void:
	_set_pause(false)

	#assert(is_instance_valid(main_menu_scene))
	get_tree().change_scene_to_file(main_menu_scene_path)
