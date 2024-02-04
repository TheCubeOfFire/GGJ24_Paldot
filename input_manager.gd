extends Node


signal player_controller_changed(player_index: int)


enum InputControllerType {
	INPUT_CONTROLLER_TYPE_NONE,
	INPUT_CONTROLLER_TYPE_KEYBOARD,
	INPUT_CONTROLLER_TYPE_GAMEPAD
}


var _player_controllers: Array[InputControllerData] = [
	InputControllerData.invalid_controller(),
	InputControllerData.invalid_controller()
]


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
			player_controller_changed.emit(other_player_index)

	_player_controllers[player_index] = controller_data
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
