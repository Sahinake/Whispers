extends Node2D

@export var bubble_scene: PackedScene
@export var spawn_interval := 0.5

@onready var timer: Timer = $BubbleSpawner

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_bubble)
	timer.start()

func _spawn_bubble():
	if bubble_scene == null:
		return
	var bubble = bubble_scene.instantiate()
	add_child(bubble)
