extends CharacterBody2D

@export var speed: float = 120.0
var sprite: AnimatedSprite2D

func _ready():
	sprite = $Sprite   # <-- aqui usa o nome exato do nó
	sprite.animation = "idle_down"
	sprite.play()

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	velocity = input_vector.normalized() * speed
	move_and_slide() 
	
	if input_vector.length() > 0:
		_play_walk_animation(input_vector)
	else:
		_play_idle_animation()

func _play_walk_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.animation = "walk_right"
		else:
			sprite.animation = "walk_left"
	else:
		if dir.y > 0:
			sprite.animation = "walk_down"
		else:
			sprite.animation = "walk_up"
	sprite.play()

func _play_idle_animation():
	var current = sprite.animation
	if "walk" in current:
		sprite.animation = current.replace("walk", "idle")
		sprite.play()
