extends CharacterBody2D

@export var speed: float = 250.0
@export var run_multiplier: float = 1.5   # multiplicador da corrida
@onready var light_area: Area2D = $Flashlight/FlashlightArea
@onready var light_polygon: CollisionPolygon2D = $Flashlight/FlashlightArea/FlashlightPolygon

var sprite: AnimatedSprite2D
var flashlight_on := false


# sinal que avisa que o inventário deve abrir/fechar
signal request_inventory_toggle

# Recursos do jogador
var oxygen := 100.0
var sanity := 100.0
var flashlight := 100.0

# Referência à UI do jogador
@export var ui_node_path: NodePath
var ui: CanvasLayer = null

func _ready():
	sprite = $Sprite
	sprite.animation = "idle_down"
	sprite.play()

	# Inicializa referência à UI
	if ui_node_path != null:
		ui = get_node(ui_node_path)

func _physics_process(delta):
	# Movimento do player
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	var current_speed = speed
	if Input.is_action_pressed("run"):   # precisa mapear "run" no Input Map como Shift
		current_speed *= run_multiplier
		
	velocity = input_vector.normalized() * current_speed
	move_and_slide()

	# Atualiza animação
	_update_animation(input_vector)

	# Faz a lanterna seguir o mouse
	$Flashlight.rotation = (get_global_mouse_position() - global_position).angle()

	# Atualiza recursos
	_update_resources(delta)

	# Atualiza UI
	if ui != null:
		ui.update_ui(oxygen, sanity, flashlight)

func _update_animation(input_vector: Vector2):
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var use_mouse = mouse_dir.length() > 0.1

	var dir = Vector2.ZERO
	if use_mouse:
		dir = mouse_dir
	else:
		dir = input_vector.normalized()
	
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
	if event.is_action_pressed("toggle_lantern"):
		flashlight_on = !flashlight_on
		$Flashlight.enabled = flashlight_on
		light_polygon.disabled = !flashlight_on
	
	if event.is_action_pressed("Cheat"):
		oxygen = 100
	
	if event.is_action_pressed("ui_cancel"):
		emit_signal("request_inventory_toggle")
		
# -------------------------------
# Recursos do jogador
# -------------------------------
func _update_resources(delta):
	# Oxigênio sempre diminui
	oxygen = clamp(oxygen - 0.1 * delta, 0, 100)
	
	if flashlight_on:
		# Se a lanterna está ligada → perde bateria
		flashlight = clamp(flashlight - 0.5 * delta, 0, 100)
		# Mas a sanidade aumenta (segurança na luz)
		sanity = clamp(sanity + 0.1 * delta, 0, 100)
	else:
		# Se a lanterna está desligada → a sanidade cai
		sanity = clamp(sanity - 0.2 * delta, 0, 100)

func change_oxygen(amount: float):
	oxygen = clamp(oxygen + amount, 0, 100)

func take_damage_trap(amount: float):
		oxygen = clamp(oxygen + amount,0,100)

func change_sanity(amount: float):
	sanity = clamp(sanity + amount, 0, 100)

func change_flashlight(amount: float):
	flashlight = clamp(flashlight + amount, 0, 100)
