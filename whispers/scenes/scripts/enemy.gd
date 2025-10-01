extends CharacterBody2D

@export var target_to_chase : CharacterBody2D

@export var attack_range: float = 50.0       # distância para atacar
@export var attack_damage: float = 10.0      # dano no player
@export var attack_cooldown: float = 2.0     # tempo de cooldown do ataque
@onready var attack_cd_timer: Timer = $AttackCooldown  # cria um Timer separado para o cooldown

@export var patrol_radius: float = 200.0      			# raio da patrulha
@onready var patrol_wait_timer: Timer = $PatrolWait   	# adicione um Timer extra na cena para a pausa

@onready var nav_chase : NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var luz : PointLight2D

var speed = 250
var dir
var start_pos
var detection: bool = false
var can_attack: bool = true   # controla cooldown
var waiting: bool = false   # controla se está parado esperando

enum State {IDLE, CHASE, BACK, ATTACK}
var current_state : State 

func _ready() -> void:
	start_pos = global_position
	dir = Vector2.ZERO
	current_state = State.IDLE
	luz = target_to_chase.get_node("Flashlight")
	luz.enemy_spotted.connect(_on_light_detect)
	
	# Inicializa o primeiro ponto de patrulha
	_set_random_patrol_point()

# ----------------------------------------
# LÓGICA PRINCIPAL
# ----------------------------------------
func _physics_process(delta: float) -> void:
	if nav_chase.is_navigation_finished() && target_to_chase.global_position == nav_chase.target_position:
		return

	match current_state:
		State.IDLE:
			if detection:
				current_state = State.CHASE
			elif !waiting:
				# pega a posição final do ponto de patrulha
				var patrol_target = nav_chase.target_position
				# calcula a distância até ele
				var dist = global_position.distance_to(patrol_target)
				
				if dist < 5.0:
					# chegou no ponto → espera
					global_position = patrol_target  # garante exatidão
					waiting = true
					velocity = Vector2.ZERO
					_update_flip()
					sprite.play("idle")
					patrol_wait_timer.start(randf_range(2.0, 3.0))
				else:
					# anda até o ponto
					dir = (nav_chase.get_next_path_position() - global_position).normalized()
					velocity = dir * (speed * 0.5)
					_update_flip()
					sprite.play("walk")

		State.CHASE:
			var dist = (target_to_chase.global_position - global_position).length()
			if !detection && dist > 300:
				# quando perde o player, atualiza ponto de patrulha
				start_pos = global_position
				waiting = true
				velocity = Vector2.ZERO
				sprite.play("idle")
				patrol_wait_timer.start(randf_range(1.0, 2.0))
				current_state = State.IDLE
			elif dist <= attack_range and can_attack:
				current_state = State.ATTACK
			else:
				dir = to_local(nav_chase.get_next_path_position()).normalized()
				velocity = dir * speed
				_update_flip()
				sprite.play("walk")

		State.BACK:
			if detection:
				current_state = State.CHASE
			elif nav_chase.is_navigation_finished():
				current_state = State.IDLE
			dir = to_local(nav_chase.get_next_path_position()).normalized()
			velocity = dir * speed
			
		State.ATTACK:
			velocity = Vector2.ZERO
			_update_flip(true)
			if sprite.animation != "attack":
				sprite.play("attack")

	move_and_slide()
	
# ----------------------------------------
# FUNÇÕES AUXILIARES
# ----------------------------------------
func movement():
	if current_state == State.ATTACK:
		return
	if current_state == State.CHASE:
		nav_chase.target_position = target_to_chase.global_position
	elif current_state == State.BACK:
		nav_chase.target_position = start_pos
		
func _update_flip(force_player := false):
	if force_player:
		sprite.flip_h = target_to_chase.global_position.x < global_position.x
	elif dir.x != 0:
		sprite.flip_h = dir.x < 0
		
func _on_animation_finished():
	if sprite.animation == "attack":
		current_state = State.CHASE

func _on_frame_changed():
	# aplica o dano no frame 3 da animação "attack"
	if sprite.animation == "attack" and sprite.frame == 3:
		_do_attack()
		
# escolhe um ponto aleatório dentro do raio
func _set_random_patrol_point():
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(50.0, patrol_radius)
	var random_point = start_pos + offset
	nav_chase.target_position = random_point
		
# ----------------------------------------
# ATAQUE
# ----------------------------------------
func _do_attack():
	if can_attack:
		if global_position.distance_to(target_to_chase.global_position) <= attack_range:
			# chama função do player para reduzir vida
			if target_to_chase.has_method("change_oxygen"):
				target_to_chase.change_oxygen(-attack_damage)
		can_attack = false
		attack_cd_timer.start(attack_cooldown)

# ----------------------------------------
# DETECÇÃO E MOVIMENTO
# ----------------------------------------

func _on_light_detect(light):
	detection = light
			
func _on_timer_timeout() -> void:
	movement()


func _on_patrol_wait_timeout() -> void:
	waiting = false
	_set_random_patrol_point()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
