extends CharacterBody2D


## Maximum horizontal speed of the character
@export_range(0.0, 1e6, 1.0, "suffix:px/s") var speed := 100.0

## Maximum distance of reach of the arms
@export_range(0.0, 1000.0, 1.0, "suffix:px") var max_target_distance := 100.0


# Target of the arms
@onready var _target: Marker2D = $Target

@onready var _skeleton_2d: Skeleton2D = $Skeleton2D


func _ready() -> void:
	#_skeleton_2d.get_modification_stack().enabled = true
	_target.position = Vector2.RIGHT * max_target_distance


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("arm_left", "arm_right", "arm_up", "arm_down")
	if not input_vector.is_zero_approx():
		_target.position = input_vector.normalized() * max_target_distance

	var h_speed := speed * Input.get_axis("move_left", "move_right")
	velocity = Vector2(h_speed, 0.0)

	move_and_slide()


