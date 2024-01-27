extends Node


func _on_time_manager_level_timeout() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
