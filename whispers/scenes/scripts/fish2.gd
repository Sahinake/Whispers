extends Node2D

@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@onready var fishA: Sprite2D = $Path2D/PathFollow2D/Fish1
@onready var fishB: Sprite2D = $Path2D/PathFollow2D/Fish2

@export var speed = 80

func _process(delta: float) -> void: 
	path_follow.progress += speed * delta
	if path_follow.progress_ratio >= 0.5:
		fishA.flip_h = true
		fishB.flip_h = true
	else:
		fishA.flip_h = false
		fishB.flip_h = false
