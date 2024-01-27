extends CharacterBody2D

@export_range(0, 1) var player_index : int

## Maximum horizontal speed of the character
@export_range(0.0, 1e6, 1.0, "suffix:px/s") var speed := 100.0

## Maximum distance osf reach of the arms
@export_range(0.0, 1000.0, 1.0, "suffix:px") var max_target_distance := 200.0

@export_range(0.0, 100.0, 1.0, "suffix:px/s") var arm_speed := 10.0


# Target of the arms
@onready var _arms_target: Marker2D = $ArmsOrigin/ArmsTarget

@onready var _skeleton_2d: Skeleton2D = $Skeleton2D

@onready var _hands: RigidBody2D = $Hands

@onready var _body_anim_sprite: AnimatedSprite2D = $BodyAnimSprite


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
