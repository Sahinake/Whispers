extends Node2D

@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@onready var crab: AnimatedSprite2D = $Path2D/PathFollow2D/AnimatedSprite2D

@export var wait_time: float = 1.0
# pixels por segundo
@export var speed = 100
var moving := true
var waiting := false

func _ready():
	crab.play("walk")
	crab.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	print("🦀 Crab começa andando.")

func _process(delta: float) -> void:
	if moving:
		path_follow.progress += speed * delta
		if  path_follow.progress_ratio >= 0.5 and not waiting:
			hide_crab()
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress = 0.0

func hide_crab() -> void:
	moving = false
	waiting = true
	crab.play("hide")
	
func _on_AnimatedSprite2D_animation_finished():
	match crab.animation:
		"hide":
			crab.play("stay")
			waiting = true
			# espera um tempo antes de sair da areia
			await get_tree().create_timer(wait_time).timeout
			sair()
		
		"unhide":
			# depois de sair, inverte direção e volta a andar
			moving = true
			waiting = false
			crab.play("walk")

func sair() -> void:
	crab.play("unhide")
