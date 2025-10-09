extends Area2D

@onready var sprite: AnimatedSprite2D = $"../Altar2"  # nó do sprite do altar
@onready var message_label: Label = get_tree().root.get_node("Game/PlayerUI/MessageLabelAltar")
@onready var putting_rune: AudioStreamPlayer2D = $"../PuttingRuna"

# Tempo até o fim do jogo após colocar a runa
@export var end_delay := 3.0  

var activated := false

func try_activate(player):
	if activated:
		return

	if not player.has_rune:
		_show_message("Você sente que falta algo aqui...")
		return

	activated = true
	_show_message("A runa se encaixa perfeitamente...")
	
	if "activated" in sprite.sprite_frames.get_animation_names():
		putting_rune.play()  # toca o som do ataque
		sprite.play("activated")
		
	await get_tree().create_timer(end_delay).timeout
	get_tree().change_scene_to_file("res://Scenes/WonScene.tscn")


func _show_message(text: String):
	if message_label:
		message_label.text = text
		message_label.modulate.a = 1.0  # aparece imediatamente

		# --- Centraliza o texto à esquerda com base no tamanho ---
		var base_x = 600  # posição base (ajuste conforme o canto inferior direito da UI)
		var char_width = 8  # largura média de cada caractere em pixels (ajuste fino conforme a fonte)
		var offset = text.length() * char_width / 2.0
		message_label.position.x = base_x - offset

		# --- Fade out ---
		var tween = create_tween()
		tween.tween_property(message_label, "modulate:a", 0.0, 2.5)
