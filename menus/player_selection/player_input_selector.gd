class_name PlayerInputSelector
extends Control


@export var player_index := -1

@export var keyboard_texture: Texture2D
@export var mouse_texture: Texture2D

@export var gamepad_textures: Array[Texture2D]

@export var unconfirmed_texture: Texture2D
@export var confirmed_texture: Texture2D

@export var select_physical_key_code: Key = KEY_NONE
@export var select_gamepad_button: JoyButton = JOY_BUTTON_INVALID

@export_node_path("PanelContainer") var inputs_panel_container_node_path: NodePath
@export_node_path("Label") var key_label_node_path: NodePath
@export_node_path("Control") var current_controller_node_path: NodePath


@onready var _inputs_panel_container := get_node(inputs_panel_container_node_path) as PanelContainer
@onready var _key_label := get_node(key_label_node_path) as Label
@onready var _current_controller_display := get_node(current_controller_node_path) as Control


func _ready() -> void:
	_key_label.text = OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(select_physical_key_code))
	InputManager.player_controller_changed.connect(_on_player_controller_changed)
	_on_player_controller_changed(player_index)


func set_player_confirmed(confirmed: bool) -> void:
	if confirmed:
		_inputs_panel_container.get("theme_override_styles/panel").texture = confirmed_texture
	else:
		_inputs_panel_container.get("theme_override_styles/panel").texture = unconfirmed_texture


func try_select_keyboard_player(input_physical_key_code: Key) -> void:
	if select_physical_key_code != input_physical_key_code:
		return

	InputManager.set_player_input(
		player_index,
		InputManager.InputControllerData.new(
			InputManager.InputControllerType.INPUT_CONTROLLER_TYPE_KEYBOARD,
			0
		)
	)


func try_select_gamepad_player(input_button: JoyButton, gamepad_index: int) -> void:
	if select_gamepad_button != input_button:
		return

	InputManager.set_player_input(
		player_index,
		InputManager.InputControllerData.new(
			InputManager.InputControllerType.INPUT_CONTROLLER_TYPE_GAMEPAD,
			gamepad_index
		)
	)


func _clear_input_display() -> void:
	for child in _current_controller_display.get_children():
		child.queue_free()


func _set_input_display_keyboard() -> void:
	_clear_input_display()

	var keyboard_texture_rect := TextureRect.new()
	keyboard_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	keyboard_texture_rect.texture = keyboard_texture
	_current_controller_display.add_child(keyboard_texture_rect)

	var mouse_texture_rect := TextureRect.new()
	mouse_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	mouse_texture_rect.texture = mouse_texture
	_current_controller_display.add_child(mouse_texture_rect)


func _set_input_display_gamepad(gamepad_index: int) -> void:
	_clear_input_display()

	if gamepad_index < 0 or gamepad_index >= gamepad_textures.size():
		return

	var gamepad_texture_rect := TextureRect.new()
	gamepad_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	gamepad_texture_rect.texture = gamepad_textures[gamepad_index]
	_current_controller_display.add_child(gamepad_texture_rect)


func _on_player_controller_changed(changed_player_index: int) -> void:
	if player_index != changed_player_index:
		return

	var controller_data := InputManager.get_player_input(changed_player_index)
	assert(is_instance_valid(controller_data))
	if not is_instance_valid(controller_data):
		_clear_input_display()
		return

	match controller_data.input_controller_type:
		InputManager.InputControllerType.INPUT_CONTROLLER_TYPE_NONE:
			_clear_input_display()

		InputManager.InputControllerType.INPUT_CONTROLLER_TYPE_KEYBOARD:
			_set_input_display_keyboard()

		InputManager.InputControllerType.INPUT_CONTROLLER_TYPE_GAMEPAD:
			_set_input_display_gamepad(controller_data.input_controller_index)
