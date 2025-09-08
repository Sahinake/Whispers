extends CharacterBody2D

const speed = 900.0
var direction:= 1
var start_position: Vector2
@export var move_distance: float = 50.0
var turning := false

func _ready() -> void:
	start_position = global_position
	$AnimationPlayer.play("peixe_nadando_dir")  # começa nadando

func _physics_process(delta: float) -> void:
	velocity.y = 0
	if turning:
		velocity.x = 0
	else:
		velocity.x = direction * speed * delta
	move_and_slide()
	if not turning and abs(global_position.x - start_position.x) >= move_distance:
		virar()
		
func virar() -> void:
	turning = true
	if direction == 1:
		$AnimationPlayer.play("peixe_vira_esq")
	else:
		$AnimationPlayer.play("peixe_vira_dir")
	direction *= -1
	turning = false
	if direction == 1:
		$AnimationPlayer.play("peixe_nadando_dir")
	else:
		$AnimationPlayer.play("peixe_nadando_esq")
