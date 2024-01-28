extends Control


@export var level1: PackedScene
@export var level2: PackedScene


@onready var _button_quit: Button = %ButtonQuit


func _ready() -> void:
	$VBoxContainer/ButtonLevel1.grab_focus()
	_button_quit.visible = OS.get_name() != "Web"


func _on_button_level1_pressed() -> void:
	get_tree().change_scene_to_packed(level1)


func _on_button_level2_pressed() -> void:
	get_tree().change_scene_to_packed(level2)


func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/credits_menu.tscn")


func _on_button_quit_pressed() -> void:
	get_tree().quit()

