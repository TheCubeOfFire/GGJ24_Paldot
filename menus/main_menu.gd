extends Control


@export var level1: PackedScene
@export var level2: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/ButtonLevel1.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_button_level1_pressed() -> void:
	get_tree().change_scene_to_packed(level1)

func _on_button_level2_pressed() -> void:
	get_tree().change_scene_to_packed(level2)

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/credits_menu.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()

