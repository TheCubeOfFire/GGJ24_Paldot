extends Node


signal player_controller_changed(player_index: int)


enum InputControllerType {
	INPUT_CONTROLLER_TYPE_NONE,
	INPUT_CONTROLLER_TYPE_KEYBOARD,
	INPUT_CONTROLLER_TYPE_GAMEPAD
}


enum InputActionType {
	JUMP,
	GRAB,
	MOVE_LEFT,
	MOVE_RIGHT,
	ARM_UP,
	ARM_DOWN,
	ARM_LEFT,
	ARM_RIGHT
}


var _player_controllers: Array[InputControllerData] = [
	InputControllerData.invalid_controller(),
	InputControllerData.invalid_controller()
]


func _ready() -> void:
	for base_action_name: String in InputActionType:
		for player_index: int in _player_controllers.size():
			InputMap.add_action(_get_action_name_from_base(player_index, base_action_name), InputMap.action_get_deadzone(base_action_name.to_lower()))


func set_player_input(player_index: int, controller_data: InputControllerData) -> void:
	var is_valid_player_index := player_index >= 0 and player_index < _player_controllers.size()
	assert(is_valid_player_index)
	if not is_valid_player_index:
		return

	# do not change controller if specified player already uses this controller
	var current_player_controller_data := _player_controllers[player_index]
	if current_player_controller_data.equals(controller_data):
		return

	# if this controller was assigned to another player, remove it
	for other_player_index: int in _player_controllers.size():
		if _player_controllers[other_player_index].equals(controller_data):
			_player_controllers[other_player_index] = InputControllerData.invalid_controller()
			_clear_all_actions(other_player_index)
			player_controller_changed.emit(other_player_index)

	_player_controllers[player_index] = controller_data

	match controller_data.input_controller_type:
		InputControllerType.INPUT_CONTROLLER_TYPE_NONE:
			_clear_all_actions(player_index)

		InputControllerType.INPUT_CONTROLLER_TYPE_KEYBOARD:
			_set_keyboard_actions(player_index)

		InputControllerType.INPUT_CONTROLLER_TYPE_GAMEPAD:
			_set_gamepad_actions(player_index, controller_data.input_controller_index)

	player_controller_changed.emit(player_index)


func get_player_count() -> int:
	return _player_controllers.size()


func get_player_input(player_index: int) -> InputControllerData:
	var is_valid_player_index := player_index >= 0 and player_index < _player_controllers.size()
	assert(is_valid_player_index)
	if not is_valid_player_index:
		return null

	return _player_controllers[player_index]


func get_keyboard_player_index() -> int:
	for player_controller_index: int in _player_controllers.size():
		if _player_controllers[player_controller_index].input_controller_type == InputControllerType.INPUT_CONTROLLER_TYPE_KEYBOARD:
			return player_controller_index

	return -1


func get_gamepad_player_index(gamepad_index: int) -> int:
	for player_controller_index: int in _player_controllers.size():
		var controller_data := _player_controllers[player_controller_index]
		if controller_data.input_controller_type == InputControllerType.INPUT_CONTROLLER_TYPE_GAMEPAD and controller_data.input_controller_index == gamepad_index:
			return player_controller_index

	return -1


func is_action_just_pressed_for_player(player_index: int, action_type: InputActionType) -> bool:
	return Input.is_action_just_pressed(get_action_name_for_player(player_index, action_type))


func is_action_just_released_for_player(player_index: int, action_type: InputActionType) -> bool:
	return Input.is_action_just_released(get_action_name_for_player(player_index, action_type))


func get_axis_for_player(player_index: int, negative_action: InputActionType, positive_action: InputActionType) -> float:
	return Input.get_axis(
		get_action_name_for_player(player_index, negative_action),
		get_action_name_for_player(player_index, positive_action)
	)


func get_vector_for_player(
	player_index: int,
	negative_x: InputActionType,
	positive_x: InputActionType,
	negative_y: InputActionType,
	positive_y: InputActionType
) -> Vector2:
	return Input.get_vector(
		get_action_name_for_player(player_index, negative_x),
		get_action_name_for_player(player_index, positive_x),
		get_action_name_for_player(player_index, negative_y),
		get_action_name_for_player(player_index, positive_y)
	)


func get_action_name_for_player(player_index: int, action_type: InputActionType) -> StringName:
	var base_action_name = InputActionType.find_key(action_type)
	assert(base_action_name != null)
	return _get_action_name_from_base(player_index, base_action_name)


func _get_action_name_from_base(player_index: int, base_action_name: String) -> StringName:
	return StringName(base_action_name.to_lower() + "_" + str(player_index))


func _clear_all_actions(player_index: int) -> void:
	for base_action_name: String in InputActionType:
		InputMap.action_erase_events(_get_action_name_from_base(player_index, base_action_name))


func _set_keyboard_actions(player_index: int) -> void:
	_clear_all_actions(player_index)
	for base_action_name: String in InputActionType:
		var events := InputMap.action_get_events(base_action_name.to_lower())
		for event: InputEvent in events:
			if is_instance_of(event, InputEventKey) or is_instance_of(event, InputEventMouse):
				InputMap.action_add_event(_get_action_name_from_base(player_index, base_action_name), event.duplicate(true))


func _set_gamepad_actions(player_index: int, gamepad_index: int) -> void:
	_clear_all_actions(player_index)
	for base_action_name: String in InputActionType:
		var events := InputMap.action_get_events(base_action_name.to_lower())
		for event: InputEvent in events:
			if is_instance_of(event, InputEventJoypadButton) or is_instance_of(event, InputEventJoypadMotion):
				var gamepad_event: InputEvent = event.duplicate(true)
				gamepad_event.device = gamepad_index
				InputMap.action_add_event(_get_action_name_from_base(player_index, base_action_name), gamepad_event)


class InputControllerData extends RefCounted:
	var input_controller_type: InputControllerType:
		get: return _input_controller_type

	var input_controller_index: int:
		get: return _input_controller_index


	var _input_controller_type := InputControllerType.INPUT_CONTROLLER_TYPE_NONE
	var _input_controller_index := 0


	func _init(p_input_controller_type: InputControllerType, p_input_controller_index: int) -> void:
		_input_controller_type = p_input_controller_type
		_input_controller_index = p_input_controller_index


	static func invalid_controller() -> InputControllerData:
		return InputControllerData.new(InputControllerType.INPUT_CONTROLLER_TYPE_NONE, 0)


	func equals(other: InputControllerData) -> bool:
		return input_controller_type == other.input_controller_type  \
			and input_controller_index == other.input_controller_index


	func is_valid() -> bool:
		return input_controller_type != InputControllerType.INPUT_CONTROLLER_TYPE_NONE
