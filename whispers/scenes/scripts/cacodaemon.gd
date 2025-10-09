extends EnemyBase

@export var attack_range: float = 50.0       # distância para atacar
@export var attack_damage: float = 10.0      # dano no player
@export var attack_cooldown: float = 0.0     # tempo de cooldown do ataque
@onready var attack_cd_timer: Timer = $AttackCooldown  # cria um Timer separado para o cooldown

@export var patrol_radius: float = 200.0      			# raio da patrulha
@onready var patrol_wait_timer: Timer = $PatrolWait   	# adicione um Timer extra na cena para a pausa
@onready var attack_sound: AudioStreamPlayer2D = $CacodeamonSound


var start_pos
var waiting: bool = false   # controla se está parado esperando

func _ready() -> void:
	start_pos = global_position
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
				hitbox.monitoring = true
				current_state = State.CHASE
			elif !waiting:
				# pega a posição final do ponto de patrulha
				var patrol_target = nav_chase.target_position
				# calcula a distância até ele
				#var dist = global_position.distance_to(patrol_target)
				
				if nav_chase.is_navigation_finished() && patrol_target == nav_chase.target_position:
					# chegou no ponto → espera
					#global_position = patrol_target  # garante exatidão
					waiting = true
					velocity = Vector2.ZERO
					_update_flip()
					sprite.play("idle")
					patrol_wait_timer.start(randf_range(2.0, 3.0))
				else:
					# anda até o ponto
					nav_movement(dir, speed*0.5)
					_update_flip()
					sprite.play("idle")
		State.CHASE:
			var dist = (target_to_chase.global_position - global_position).length()
			if !detection && dist > 400:
				# quando perde o player, atualiza ponto de patrulha
				start_pos = global_position
				waiting = true
				velocity = Vector2.ZERO
				sprite.play("idle")
				patrol_wait_timer.start(randf_range(1.0, 2.0))
				hitbox.monitoring = false
				current_state = State.IDLE
			elif can_attack:
				current_state = State.ATTACK
			else:
				nav_movement(dir, speed)
				_update_flip()
				sprite.play("chase")

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
			#if sprite.animation != "attack":
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

# ----------------------------------------
# ATAQUE
# ----------------------------------------
func _on_animation_finished():
	if sprite.animation == "attack":
		current_state = State.CHASE

func _on_frame_changed():
	# aplica o dano no frame 3 da animação "attack"
	if sprite.animation == "attack" and sprite.frame == 2:
		do_attack(0, attack_damage)
		attack_sound.play()  # toca o som do ataque
		
# escolhe um ponto aleatório dentro do raio
func _set_random_patrol_point():
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(50.0, patrol_radius)
	var random_point = start_pos + offset
	nav_chase.target_position = random_point
		

# ----------------------------------------
# DETECÇÃO E MOVIMENTO
# ----------------------------------------

func _on_timer_timeout() -> void:
	movement()

func _on_patrol_wait_timeout() -> void:
	waiting = false
	_set_random_patrol_point()
	
