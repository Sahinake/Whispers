extends EnemyBase

@onready var attack_sound: AudioStreamPlayer2D = $GhostSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var can_fade: bool = true
@onready var damage: float = 10.0
@onready var sleeping: bool = true
@onready var sleep: Timer = $Sleep

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			var dist = (target_to_chase.global_position - global_position).length()
			if dist < 250 && sleeping && !detection:
				_update_flip()
				animation_player.play("arise")
		State.CHASE:
			if can_fade:
				if detection:
					current_state = State.BACK
				elif can_attack:
					current_state = State.ATTACK
				else:
					_update_flip()
					animation_player.play("chase")
			else:
				if can_attack:
					velocity = Vector2.ZERO
					_update_flip()
					animation_player.play_backwards("chase")
				else:	
					dir = to_local(nav_chase.get_next_path_position()).normalized()
					velocity = dir * speed
					
		State.ATTACK:
			velocity = Vector2.ZERO
			_update_flip()
			animation_player.play("attack")
		
		State.BACK:
			_update_flip()
			animation_player.play("stop")
	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		current_state = State.CHASE
	elif anim_name == "arise":
		sleeping = false
		current_state = State.CHASE
	elif anim_name == "stop":
			sleep.start()
			current_state = State.IDLE
	elif anim_name == "chase":
		can_fade = !can_fade
		if can_attack && can_fade:
			current_state = State.ATTACK


func movement():
	if current_state == State.CHASE:
		nav_chase.target_position = target_to_chase.global_position
	elif current_state == State.BACK:
		nav_chase.target_position = global_position

func _on_path_update_timeout() -> void:
	movement()

func _on_animated_sprite_2d_frame_changed() -> void:
	if animation_player.current_animation == "attack" and sprite.frame == 4:
		do_attack(1, damage)
		attack_sound.play()  # toca o som do ataque

func _on_sleep_timeout() -> void:
	sleeping =  true
