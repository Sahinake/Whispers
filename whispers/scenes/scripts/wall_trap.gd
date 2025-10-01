extends Node2D
var speed := 100

@onready var path_follow : PathFollow2D = $See/Path2D/PathFollow2D
@onready var lance: AnimatedSprite2D = $See/Path2D/PathFollow2D/Sprite2D
@onready var see: Area2D = $Node2D


func _ready() -> void:
	see.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"): # garante que é o jogador
		lance.play("on")
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false
		anim.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
		animation_playing = false

func drawLance():
	if path_follow.progress_ratio == 0 or path_follow.progress_ratio == 1:
		lance.play("off")
	else:
		lance.play("on")

func _process(delta: float) -> void:
	path_follow.progress += speed * delta
	if path_follow.progress_ratio == 1:
		print("Acabou")
