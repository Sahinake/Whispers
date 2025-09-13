extends Node2D

@export var bubble_scene: PackedScene
@export var spawn_interval := 1

@onready var timer: Timer = $BubbleSpawner

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_bubble)
	timer.start()

func _spawn_bubble():
	if get_tree().paused:
		return
	if bubble_scene == null:
		return
	var bubble = bubble_scene.instantiate()
	bubble.start_frame = randi() % bubble.sprite_frames.get_frame_count(bubble.animation_name)
	add_child(bubble)
