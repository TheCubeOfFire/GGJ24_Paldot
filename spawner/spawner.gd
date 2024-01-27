class_name Spawner
extends Marker2D

@export var pie: PackedScene

signal created(pie: Pie)

func spawn() -> void:
	# create a new pie
	var new_pie := pie.instantiate() as Pie

	add_child(new_pie)
	created.emit(new_pie)


