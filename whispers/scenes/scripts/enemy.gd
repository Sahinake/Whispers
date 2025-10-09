extends CharacterBody2D
class_name EnemyBase

enum State {IDLE, CHASE, BACK, ATTACK}

@onready var target_to_chase : CharacterBody2D = get_tree().get_first_node_in_group("Player")
@export var speed: float = 350.0

@onready var hitbox: Area2D = $HitBox
@onready var nav_chase: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite


@onready var path_update: Timer = $PathUpdate
@onready var detection: bool = false
@onready var can_attack: bool = false
@onready var current_state : State = State.IDLE
@onready var dir: Vector2 = Vector2.ZERO


func _update_flip(force_player := false):
	if force_player:
		sprite.flip_h = target_to_chase.global_position.x < global_position.x
	elif dir.x != 0:
		sprite.flip_h = dir.x < 0
		


func nav_movement(direction, spd):
	direction = to_local(nav_chase.get_next_path_position()).normalized()
	var new_velocity = direction * spd
	if nav_chase.avoidance_enabled:
		nav_chase.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_attack = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		can_attack = false	


func do_attack(type, damage):
	if can_attack:
		match type:
			0:
				if target_to_chase.has_method("change_oxygen"):
					target_to_chase.change_oxygen(-damage)
			1:
				if target_to_chase.has_method("change_sanity"):
					target_to_chase.change_sanity(-damage)
			2: 
				if target_to_chase.has_method("change_flashlight"):
					target_to_chase.change_flashlight(-damage)

func play_patrol(wait: bool, mod_spd: float):
	if !wait:
		# pega a posição final do ponto de patrulha
		var patrol_target = nav_chase.target_position
		# calcula a distância até ele
		var dist = global_position.distance_to(patrol_target)
				
		if dist < 5.0:
			# chegou no ponto → espera
			global_position = patrol_target  # garante exatidão
			wait = true
			velocity = Vector2.ZERO
			_update_flip()
			sprite.play("idle")
			#patrol_wait_timer.start(randf_range(2.0, 3.0))
		else:
			# anda até o ponto
			nav_movement(dir, speed*mod_spd)
