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

var _joint: Joint2D = null


func grab(by: PhysicsBody2D) -> void:
	if _state != PieState.READY:
		return

	_joint = PinJoint2D.new()
	_joint.node_a = by.get_path()
	_joint.node_b = get_path()
	add_child(_joint)

	_state = PieState.GRABBED
	#remove the floor layer for the collisions when grabbed
	collision_mask &= ~(1 << 0)
	grabbed.emit()


func launch() -> void:
	if not is_grabbed:
		return

	if is_instance_valid(_joint):
		_joint.queue_free()
		_joint = null

	_state = PieState.LAUNCHED
	collision_mask |= 1 << 0
	launched.emit()

	if not get_colliding_bodies().is_empty():
		queue_free.call_deferred()


func _on_body_entered(_body: Node) -> void:
	if is_launched:
		# call_deferred to allow player to receive the pie
		queue_free.call_deferred()
