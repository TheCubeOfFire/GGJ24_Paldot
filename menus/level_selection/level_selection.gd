extends Control


@export_file var previous_scene_path: String

@export var level_control_scene: PackedScene
@export var levels_data: Array[LevelData] = []


@onready var _levels_grid_container := $LevelsGridContainer as GridContainer
@onready var _back_button := $BackButton as Button


func _ready() -> void:
	var first_control: LevelSelectionElementControl = null

	for level_data: LevelData in levels_data:
		var level_control := level_control_scene.instantiate() as LevelSelectionElementControl
		level_control.level_data = level_data
		_levels_grid_container.add_child(level_control)

		if not is_instance_valid(first_control):
			first_control = level_control

	if is_instance_valid(first_control):
		first_control.focus_button()
	else:
		_back_button.grab_focus.call_deferred()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(previous_scene_path)
