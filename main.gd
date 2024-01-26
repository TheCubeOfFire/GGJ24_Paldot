extends Node

@export var pie: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pie_timer_timeout():
# create a new pie
	var pie = pie.instantiate()

#choose a random location
	var pie_spawn_location = $Path2D/PathFollow2D
	pie_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	#var direction = pie_spawn_location.rotation + PI / 2

#set position random
	pie.position = pie_spawn_location.position

	#pie.rotation = direction

	add_child(pie)


func new_game():
	$pie_spawn_timer.start()
















