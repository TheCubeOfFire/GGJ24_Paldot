extends Control


@onready var _p1_score_label: Label = $P1ScoreLabel
@onready var _p2_score_label: Label = $P2ScoreLabel


func _ready() -> void:
	_p1_score_label.text = str(ScoreManager.p1_score) + " points"
	_p2_score_label.text = str(ScoreManager.p2_score) + " points"
	$MainMenuButton.grab_focus()

func _on_main_menu_button_pressed() -> void:
	ScoreManager.reset()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
