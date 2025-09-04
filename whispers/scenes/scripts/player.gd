extends CharacterBody2D

@export var speed: float = 250.0
var sprite: AnimatedSprite2D
var lantern_on := true

func _ready():
	sprite = $Sprite
	sprite.animation = "idle_down"
	sprite.play()

func _physics_process(delta):
	# Movimento do player
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	velocity = input_vector.normalized() * speed
	move_and_slide()
	
	# Atualiza animação olhando para o mouse ou teclado
	_update_animation(input_vector)
	
	# Faz a lanterna seguir o mouse
	$PointLight2D.rotation = (get_global_mouse_position() - global_position).angle()

func _update_animation(input_vector: Vector2):
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var use_mouse = mouse_dir.length() > 0.1  # se o mouse está longe do player

	var dir = Vector2.ZERO
	if use_mouse:
		dir = mouse_dir
	else:
		dir = input_vector.normalized()
	
	# Escolhe animação
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.animation = "walk_right" if velocity.length() > 0 else "idle_right"
		else:
			sprite.animation = "walk_left" if velocity.length() > 0 else "idle_left"
	else:
		if dir.y > 0:
			sprite.animation = "walk_down" if velocity.length() > 0 else "idle_down"
		else:
			sprite.animation = "walk_up" if velocity.length() > 0 else "idle_up"
	
	sprite.play()

func _input(event):
	if event.is_action_pressed("toggle_lantern"):  # tecla T
		lantern_on = !lantern_on
		$PointLight2D.enabled = lantern_on
