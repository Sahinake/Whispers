extends Area2D
@onready var anim := $AnimatedSprite2D
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var damage_done := false
var player_inside := false
var animation_playing := false  # Controla se a animação está em andamento

func _process(delta: float) -> void:
	if player_inside and anim.animation == "default" and anim.frame == 3 and not damage_done:
		if player.has_method("take_damage_trap"):
			player.take_damage_trap(-10)
			damage_done = true
			print("Tomou dano")
		

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	anim.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"): # garante que é o jogador
		player_inside = true
		start_trap_animation()
		animation_playing = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		animation_playing = false
		#anim.play("idle")
		# Não faz nada aqui, a animação continuará até o final

func start_trap_animation() -> void:
	animation_playing = true
	damage_done = false
	anim.play("default")
	print("💥 Armadilha ativada!")

func _on_AnimatedSprite2D_animation_finished():
	# Verifica se a animação que terminou foi a "default"
	if anim.animation == "default":
		#print("Executou aqui")
		animation_playing = false
		
		# Se o player ainda estiver na área, volta para idle (NÃO reinicia)
		if player_inside:
			start_trap_animation()
			print("✅ Animação completada, player ainda na área, voltando para idle")
		else:
			# Se o player saiu, volta para idle
			anim.play("idle")
			print("🔄 Armadilha voltou ao estado inicial")
