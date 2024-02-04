extends Control


@export var play_scene: PackedScene


@onready var _button_start := %ButtonStart as Button
@onready var _button_quit := %ButtonQuit as Button


func _ready() -> void:
	_button_start.grab_focus.call_deferred()
	_button_quit.visible = OS.get_name() != "Web"


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_packed(play_scene)


func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/credits_menu.tscn")


func _on_button_quit_pressed() -> void:
	get_tree().quit()
