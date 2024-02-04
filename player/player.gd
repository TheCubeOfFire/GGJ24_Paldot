extends CharacterBody2D

@export_range(0, 1) var player_index : int

## Maximum horizontal speed of the character
@export_range(0.0, 1e6, 1.0, "suffix:px/s") var speed := 300.0

## Maximum distance osf reach of the arms
@export_range(0.0, 1000.0, 1.0, "suffix:px") var max_target_distance := 200.0

@export_range(0.0, 100.0, 1.0, "suffix:px/s") var arm_speed := 10.0

@export_range(0.0, 1e6, 1.0, "suffix:px/s") var jump_impulse := 1000.0

@export_range(0.0, 1e6, 1.0, "suffix:px/s^2") var gravity := 2000.0

@export_range(0.0, 10.0, 0.1) var falling_gravity_multiplier := 2.0

@export var cream_disappear_time := 2.0


var _grabbed_pie: Pie = null
var _cream_tween: Tween = null


@onready var _arms_target: Marker2D = $ArmsOrigin/ArmsTarget

@onready var _skeleton_2d: Skeleton2D = $Skeleton2D

@onready var _hands: RigidBody2D = $Hands

@onready var _body_anim_sprite: AnimatedSprite2D = $BodyAnimSprite

#arm
@onready var _right_arm_sprite: Sprite2D = $Skeleton2D/Body/RightShoulder/RightArm/Sprite2D
@onready var _left_arm_sprite: Sprite2D = $Skeleton2D/Body/LeftShoulder/LeftArm/Sprite2D

#forearm opened
@onready var _right_forearm_sprite: Sprite2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHandOpened
@onready var _left_forearm_sprite: Sprite2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHandOpened

#forearm closed
@onready var _left_forearm_sprite_closed: Sprite2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHandClose
@onready var _right_forearm_sprite_closed: Sprite2D =$Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHandClosed

@onready var _right_hand_area: Area2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHand/Area2D
@onready var _left_hand_area: Area2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHand/Area2D

@onready var _right_hand_attachment: CharacterBody2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHand/Area2D/RightHandAttachment
@onready var _left_hand_attachment: CharacterBody2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHand/Area2D/LeftHandAttachment

@onready var pie_detector: Area2D = $PieDetector


func _ready() -> void:
	_skeleton_2d.get_modification_stack().enabled = true
	_arms_target.position = Vector2.RIGHT * max_target_distance
	_body_anim_sprite.play("Idle")


func _physics_process(_delta: float) -> void:
	_update_arms_position()
	_update_horizontal_speed()
	_update_vertical_speed()

	move_and_slide()

	if InputManager.is_action_just_pressed_for_player(player_index, InputManager.InputActionType.GRAB):
		_grab()

	if InputManager.is_action_just_released_for_player(player_index, InputManager.InputActionType.GRAB):
		_ungrab()


func _update_arms_position() -> void:
	var input_vector := InputManager.get_vector_for_player(
		player_index,
		InputManager.InputActionType.ARM_LEFT,
		InputManager.InputActionType.ARM_RIGHT,
		InputManager.InputActionType.ARM_UP,
		InputManager.InputActionType.ARM_DOWN
	)

	_arms_target.position = input_vector * max_target_distance

	_hands.linear_velocity = (_arms_target.global_position - _hands.global_position) * arm_speed


func _update_horizontal_speed() -> void:
	var horizontal_input := InputManager.get_axis_for_player(
		player_index,
		InputManager.InputActionType.MOVE_LEFT,
		InputManager.InputActionType.MOVE_RIGHT,
	)

	velocity.x = speed * horizontal_input

	if not velocity.is_zero_approx():
		_body_anim_sprite.play("Move")
	else:
		_body_anim_sprite.play("Idle")


func _update_vertical_speed() -> void:
	if is_on_floor():
		if InputManager.is_action_just_pressed_for_player(player_index, InputManager.InputActionType.JUMP):
			velocity.y -= jump_impulse

	if velocity.y < 0.0:
		if InputManager.is_action_just_released_for_player(player_index, InputManager.InputActionType.JUMP):
			velocity.y = velocity.y * 0.5
		velocity.y += gravity * get_physics_process_delta_time()
	else:
		velocity.y += falling_gravity_multiplier * gravity * get_physics_process_delta_time()


func _grab() -> void:
	_toogle_arm_sprite()
	if is_instance_valid(_grabbed_pie):
		_ungrab()

	var is_pie := func(pie_node: Node2D) -> bool:
		return is_instance_of(pie_node, Pie)

	var left_pie_nodes := _left_hand_area.get_overlapping_bodies().filter(is_pie)
	var right_pie_nodes := _right_hand_area.get_overlapping_bodies().filter(is_pie)

	if left_pie_nodes.is_empty() and right_pie_nodes.is_empty():
		return

	var picked_pie_index := randi_range(0, left_pie_nodes.size() + right_pie_nodes.size() - 1)

	if picked_pie_index < left_pie_nodes.size():
		_grabbed_pie = left_pie_nodes[picked_pie_index]
		_grabbed_pie.grab(_left_hand_attachment)
	else:
		_grabbed_pie = right_pie_nodes[picked_pie_index - left_pie_nodes.size()]
		_grabbed_pie.grab(_right_hand_attachment)

	_grabbed_pie.grabbed.connect(_on_pie_grabbed)


func _ungrab() -> void:
	_toogle_arm_sprite()
	if is_instance_valid(_grabbed_pie):
		#add the floor layer for the collisions when ungrabbed
		_grabbed_pie.launch()
		_grabbed_pie.grabbed.disconnect(_on_pie_grabbed)
		_grabbed_pie = null


func _on_pie_grabbed() -> void:
	if is_instance_valid(_grabbed_pie):
		_grabbed_pie.grabbed.disconnect(_on_pie_grabbed)
		_grabbed_pie = null


func _on_pie_detector_body_entered(body: Node2D) -> void:
	if not is_instance_of(body, Pie):
		return

	var pie := body as Pie

	# compare with own pie in case of grabbing to avoid self-pieing
	if pie.is_launched or (pie.is_grabbed and pie != _grabbed_pie):
		pie.queue_free()

		if player_index == 0:
			ScoreManager.increment_p2_score()
		else:
			ScoreManager.increment_p1_score()

		_animate_cream()


func _animate_cream() -> void:
	var cream_covered_parts: Array[CanvasItem] = [
		_body_anim_sprite,
		_left_arm_sprite,
		_left_forearm_sprite,
		_right_arm_sprite,
		_right_forearm_sprite,
		_left_forearm_sprite_closed,
		_right_forearm_sprite_closed

	]

	if is_instance_valid(_cream_tween):
		_cream_tween.kill()
		_cream_tween = null

	var shader_materials: Array[ShaderMaterial] = []

	for part: CanvasItem in cream_covered_parts:
		assert(is_instance_of(part.material, ShaderMaterial))
		var shader_material := part.material as ShaderMaterial
		shader_material.set_shader_parameter("cream_quantity", 1.0)
		shader_materials.append(shader_material)

	_cream_tween = create_tween()
	_cream_tween.set_trans(Tween.TRANS_CIRC)
	_cream_tween.set_ease(Tween.EASE_IN)
	_cream_tween.set_parallel(true)
	for shader_material: ShaderMaterial in shader_materials:
		_cream_tween.tween_property(shader_material, "shader_parameter/cream_quantity", 0.0, cream_disappear_time)

	await _cream_tween.finished
	_cream_tween = null


func _toogle_arm_sprite() ->void:
	_left_forearm_sprite_closed.visible = not _left_forearm_sprite_closed.visible
	_left_forearm_sprite.visible = not _left_forearm_sprite.visible
	_right_forearm_sprite.visible = not _right_forearm_sprite.visible
	_right_forearm_sprite_closed.visible = not _right_forearm_sprite_closed.visible


