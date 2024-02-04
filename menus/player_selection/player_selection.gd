extends Control


@export var next_scene: PackedScene

@export var player_confirm_physical_key: Key = KEY_NONE
@export var player_confirm_gamepad_button: JoyButton = JOY_BUTTON_INVALID
@export var player_input_selectors: Array[PlayerInputSelector] = []


var _confirmed_players: Array[bool] = []


func _ready() -> void:
	InputManager.player_controller_changed.connect(_on_player_controller_changed)
	_confirmed_players.resize(InputManager.get_player_count())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return

	if is_instance_of(event, InputEventKey):
		var key_event := event as InputEventKey

		if _is_keyboard_player_confirmed():
			return

		for player_input_selector: PlayerInputSelector in player_input_selectors:
			player_input_selector.try_select_keyboard_player(key_event.physical_keycode)

		if key_event.physical_keycode == player_confirm_physical_key:
			_set_keyboard_player_confirmed()
	elif is_instance_of(event, InputEventJoypadButton):
		var button_event := event as InputEventJoypadButton

		if _is_gamepad_player_confirmed(button_event.device):
			return

		for player_input_selector: PlayerInputSelector in player_input_selectors:
			player_input_selector.try_select_gamepad_player(button_event.button_index, button_event.device)

		if button_event.button_index == player_confirm_gamepad_button:
			_set_gamepad_player_confirmed(button_event.device)


func _is_keyboard_player_confirmed() -> bool:
	var keyboard_player_index := InputManager.get_keyboard_player_index()
	if keyboard_player_index < 0 or keyboard_player_index >= _confirmed_players.size():
		return false

	return _confirmed_players[keyboard_player_index]


func _set_keyboard_player_confirmed() -> void:
	var keyboard_player_index := InputManager.get_keyboard_player_index()
	if keyboard_player_index < 0 or keyboard_player_index >= _confirmed_players.size():
		return

	_confirmed_players[keyboard_player_index] = true
	_on_confirmed_status_changed(keyboard_player_index)


func _is_gamepad_player_confirmed(gamepad_index: int) -> bool:
	var gamepad_player_index := InputManager.get_gamepad_player_index(gamepad_index)
	if gamepad_player_index < 0 or gamepad_player_index >= _confirmed_players.size():
		return false

	return _confirmed_players[gamepad_player_index]


func _set_gamepad_player_confirmed(gamepad_index: int) -> void:
	var gamepad_player_index := InputManager.get_gamepad_player_index(gamepad_index)
	if gamepad_player_index < 0 or gamepad_player_index >= _confirmed_players.size():
		return

	_confirmed_players[gamepad_player_index] = true
	_on_confirmed_status_changed(gamepad_player_index)


func _on_player_controller_changed(player_index: int) -> void:
	if player_index >= 0 and player_index < _confirmed_players.size():
		_confirmed_players[player_index] = false
		_on_confirmed_status_changed(player_index)


func _on_confirmed_status_changed(player_index: int) -> void:
	for player_input_selector in player_input_selectors:
		if player_input_selector.player_index == player_index:
			player_input_selector.set_player_confirmed(_confirmed_players[player_index])

	var all_player_confirmed := true
	for confirmed_player: bool in _confirmed_players:
		all_player_confirmed = all_player_confirmed && confirmed_player

	if all_player_confirmed:
		get_tree().change_scene_to_packed(next_scene)
