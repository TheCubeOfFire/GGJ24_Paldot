class_name Spawner
extends Marker2D

@export var pie: PackedScene
var is_spawner_available := true

signal created(pie: Pie)

func spawn() -> void:
	if !is_spawner_available:
		return
	# create a new pie
	var new_pie := pie.instantiate() as Pie
	new_pie.position= position
	get_parent().add_child(new_pie)
	created.emit(new_pie)
	new_pie.grabbed.connect(_on_spawned_pie_grabbed)
	is_spawner_available = false


func _on_spawned_pie_grabbed() ->void:
	is_spawner_available = true;
