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


var _grabbed_pie: Pie = null


@onready var _arms_target: Marker2D = $ArmsOrigin/ArmsTarget

@onready var _skeleton_2d: Skeleton2D = $Skeleton2D

@onready var _hands: RigidBody2D = $Hands

@onready var _body_anim_sprite: AnimatedSprite2D = $BodyAnimSprite
@onready var _right_arm_sprite: Sprite2D = $Skeleton2D/Body/RightShoulder/RightArm/Sprite2D
@onready var _right_forearm_sprite: Sprite2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/Sprite2D
@onready var _left_arm_sprite: Sprite2D = $Skeleton2D/Body/LeftShoulder/LeftArm/Sprite2D
@onready var _left_forearm_sprite: Sprite2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/Sprite2D

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

	var grab_action: String
	if player_index == 0:
		grab_action = "grab_p1"
	else:
		grab_action = "grab_p2"

	if Input.is_action_just_pressed(grab_action):
		_grab()

	if Input.is_action_just_released(grab_action):
		_ungrab()


func _update_arms_position() -> void:
	var input_vector
	if player_index == 0:
		input_vector = Input.get_vector("arm_left_p1", "arm_right_p1", "arm_up_p1", "arm_down_p1")
	else:
		input_vector = Input.get_vector("arm_left_p2", "arm_right_p2", "arm_up_p2", "arm_down_p2")

	if not input_vector.is_zero_approx():
		_arms_target.position = input_vector.normalized() * max_target_distance

	_hands.linear_velocity = (_arms_target.global_position - _hands.global_position) * arm_speed


func _update_horizontal_speed() -> void:
	var h_speed: float
	if player_index == 0:
		h_speed = speed * Input.get_axis("move_left_p1", "move_right_p1")
	else:
		h_speed = speed * Input.get_axis("move_left_p2", "move_right_p2")
	velocity.x = h_speed

	if not velocity.is_zero_approx():
		_body_anim_sprite.play("Move")
	else:
		_body_anim_sprite.play("Idle")


func _update_vertical_speed() -> void:
	var jump_action := "jump_p1" if player_index == 0 else "jump_p2"

	if is_on_floor():
		if Input.is_action_just_pressed(jump_action):
			velocity.y -= jump_impulse

	if velocity.y < 0.0:
		if Input.is_action_just_released(jump_action):
			velocity.y = velocity.y * 0.5
		velocity.y += gravity * get_physics_process_delta_time()
	else:
		velocity.y += falling_gravity_multiplier * gravity * get_physics_process_delta_time()


func _grab() -> void:
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


func _ungrab() -> void:
	if is_instance_valid(_grabbed_pie):
		#add the floor layer for the collisions when ungrabbed
		_grabbed_pie.launch()
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
		_right_forearm_sprite
	]

	var shader_materials: Array[ShaderMaterial] = []

	for part: CanvasItem in cream_covered_parts:
		assert(is_instance_of(part.material, ShaderMaterial))
		var shader_material := part.material as ShaderMaterial
		shader_material.set_shader_parameter("cream_quantity", 1.0)
		shader_materials.append(shader_material)

	var cream_tween := create_tween()
	cream_tween.set_parallel(true)
	for shader_material: ShaderMaterial in shader_materials:
		cream_tween.tween_property(shader_material, "shader_parameter/cream_quantity", 0.0, 2.0)
	await cream_tween.finished
