class_name LevelSelectionElementControl
extends Control


var level_data: LevelData


@onready var _select_level_button := $SelectLevelButton as Button


func _ready() -> void:
	_select_level_button.icon = level_data.level_icon
	_select_level_button.pressed.connect(_on_button_pressed)


func focus_button() -> void:
	_select_level_button.grab_focus.call_deferred()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(level_data.level_scene_path)
