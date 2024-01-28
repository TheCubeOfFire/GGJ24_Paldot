extends Node2D

@onready var sproutchs : Array [AudioStreamPlayer2D] = [$Sproutch1, $Sproutch2, $Sproutch3,$Sproutch4]
@export var rire : AudioStreamPlayer2D
#var sproutchs = [AudioStreamPlayer2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for sproutch in sproutchs_path:
		#sproutchs.append(get_node(sproutch))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func sproutch() ->void:
	sproutchs.pick_random().play()

func start_rires() -> void:
	rire.play()

func stop_rires() -> void:
	rire.stop()
