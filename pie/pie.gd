class_name Pie
extends RigidBody2D


enum PieState {
	READY,
	GRABBED,
	LAUNCHED,
}


signal grabbed
signal launched


var is_grabbed: bool:
	get: return _state == PieState.GRABBED

var is_launched: bool:
	get: return _state == PieState.LAUNCHED


var _state := PieState.READY


func grab() -> void:
	_state = PieState.GRABBED
	grabbed.emit()


func launch() -> void:
	_state = PieState.LAUNCHED
	launched.emit()

	if not get_colliding_bodies().is_empty():
		queue_free.call_deferred()


func _on_body_entered(_body: Node) -> void:
	if is_launched:
		# call_deferred to allow player to receive the pie
		queue_free.call_deferred()
