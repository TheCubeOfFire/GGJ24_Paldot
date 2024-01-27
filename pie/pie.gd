class_name Pie
extends RigidBody2D

signal destroyed
signal grabbed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func destroy() ->void:
	destroyed.emit()

func grab() ->void:
	grabbed.emit()


