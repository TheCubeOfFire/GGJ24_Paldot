extends Node


var pie_count := 0
#const MAX_PIE := 4

@export var spawner_paths : Array [NodePath] = []

var spawners = []
@onready var pie_spawn_timer: Timer = $pie_spawn_timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pie_spawn_timer.start()
	for spawner_path in spawner_paths:
		spawners.append(get_node(spawner_path))
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pie_spawn_timer_timeout() -> void:
	#if pie_count >= MAX_PIE:
		#return
	var currentSpawner := spawners.pick_random() as Spawner
	currentSpawner.spawn()


func _on_pie_created(pie: Pie) -> void:
	pie_count = pie_count + 1
	pie.tree_exited.connect(_on_pie_destroyed)

func _on_pie_destroyed() ->void:
	pie_count = pie_count - 1
