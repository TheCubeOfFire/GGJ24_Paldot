extends CharacterBody2D

@export_range(0, 1) var player_index : int

## Maximum horizontal speed of the character
@export_range(0.0, 1e6, 1.0, "suffix:px/s") var speed := 100.0

## Maximum distance osf reach of the arms
@export_range(0.0, 1000.0, 1.0, "suffix:px") var max_target_distance := 200.0

@export_range(0.0, 100.0, 1.0, "suffix:px/s") var arm_speed := 10.0


var _grabbed_pie: RigidBody2D = null
var _left_grabbed_pie_joint: Joint2D = null
var _right_grabbed_pie_joint: Joint2D = null


@onready var _arms_target: Marker2D = $ArmsOrigin/ArmsTarget

@onready var _skeleton_2d: Skeleton2D = $Skeleton2D

@onready var _hands: RigidBody2D = $Hands

@onready var _body_anim_sprite: AnimatedSprite2D = $BodyAnimSprite

@onready var _right_hand_area: Area2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHand/Area2D
@onready var _left_hand_area: Area2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHand/Area2D

@onready var _right_hand_attachment: CharacterBody2D = $Skeleton2D/Body/RightShoulder/RightArm/RightForearm/RightHand/Area2D/RightHandAttachment
@onready var _left_hand_attachment: CharacterBody2D = $Skeleton2D/Body/LeftShoulder/LeftArm/LeftForearm/LeftHand/Area2D/LeftHandAttachment


func _ready() -> void:
	_skeleton_2d.get_modification_stack().enabled = true
	_arms_target.position = Vector2.RIGHT * max_target_distance
	_body_anim_sprite.play("Idle")


func _physics_process(delta: float) -> void:
	var input_vector
	if player_index == 0:
		input_vector = Input.get_vector("arm_left_p1", "arm_right_p1", "arm_up_p1", "arm_down_p1")
	else:
		input_vector = Input.get_vector("arm_left_p2", "arm_right_p2", "arm_up_p2", "arm_down_p2")

	if not input_vector.is_zero_approx():
		_arms_target.position = input_vector.normalized() * max_target_distance

	var h_speed
	if player_index == 0:
		h_speed = speed * Input.get_axis("move_left_p1", "move_right_p1")
	else:
		h_speed = speed * Input.get_axis("move_left_p2", "move_right_p2")
	velocity = Vector2(h_speed, 0.0)

	if not velocity.is_zero_approx():
		_body_anim_sprite.play("Move")
	else:
		_body_anim_sprite.play("Idle")

	_hands.linear_velocity = (_arms_target.global_position - _hands.global_position) * arm_speed

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


func _grab() -> void:
	if is_instance_valid(_grabbed_pie):
		_ungrab()

	var pie_nodes := _left_hand_area.get_overlapping_bodies()
	pie_nodes.append_array(_right_hand_area.get_overlapping_bodies())

	pie_nodes = pie_nodes.filter(func(pie_node: Node2D) -> bool:
		return is_instance_of(pie_node, RigidBody2D)
	)

	if pie_nodes.is_empty():
		return

	_grabbed_pie = pie_nodes.pick_random() as RigidBody2D

	var left_joint := PinJoint2D.new()
	left_joint.node_a = _left_hand_attachment.get_path()
	left_joint.node_b = _grabbed_pie.get_path()
	_left_hand_attachment.add_child(left_joint)
	_left_grabbed_pie_joint = left_joint

	var right_joint := PinJoint2D.new()
	right_joint.node_a = _right_hand_attachment.get_path()
	right_joint.node_b = _grabbed_pie.get_path()
	_right_hand_attachment.add_child(right_joint)
	_right_grabbed_pie_joint = right_joint


func _ungrab() -> void:
	if is_instance_valid(_left_grabbed_pie_joint):
		_left_grabbed_pie_joint.queue_free()
		_left_grabbed_pie_joint = null

	if is_instance_valid(_right_grabbed_pie_joint):
		_right_grabbed_pie_joint.queue_free()
		_right_grabbed_pie_joint = null

	if is_instance_valid(_grabbed_pie):
		_grabbed_pie = null
