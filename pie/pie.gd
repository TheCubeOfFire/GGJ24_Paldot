class_name Pie
extends RigidBody2D


enum PieState {
	READY,
	GRABBED,
	LAUNCHED,
}


signal grabbed
signal launched


@export var cream_particles_scene: PackedScene


var is_grabbed: bool:
	get: return _state == PieState.GRABBED

var is_launched: bool:
	get: return _state == PieState.LAUNCHED


var _state := PieState.READY

var _joint: Joint2D = null

var _body_to_attach: Node2D = null


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_instance_valid(_body_to_attach):
		if is_instance_valid(_joint):
			state.transform = Transform2D(0.0, _body_to_attach.global_position)
			_body_to_attach.add_child.call_deferred(_joint)

		_body_to_attach = null


func _exit_tree() -> void:
	SoundManager.sproutch()

	if is_instance_valid(_joint):
		_joint.queue_free()
		_joint = null

	_spawn_particles()


func _spawn_particles() -> void:
	var cream_particles := cream_particles_scene.instantiate() as CPUParticles2D
	cream_particles.emitting = true

	# emits an error when the scene is destroyed,
	# but it does not prevent the game from working as intended
	# TODO properly check if scene is being destroyed
	get_tree().root.add_child(cream_particles)

	# only position is taken so particles are always emitted upwards
	cream_particles.global_position = global_position

	cream_particles.finished.connect(func(): cream_particles.queue_free())


func grab(by: PhysicsBody2D) -> void:
	if is_grabbed and is_instance_valid(_joint):
		_joint.queue_free()
		_joint = null

	_joint = PinJoint2D.new()
	_joint.node_a = by.get_path()
	_joint.node_b = get_path()

	_body_to_attach = by

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
