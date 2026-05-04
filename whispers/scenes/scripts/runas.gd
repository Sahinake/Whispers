extends "res://Scenes/Scripts/interactiveArea.gd"

@export var rune_id := ""

func _ready():
	# Gera um ID único se esquecer de configurar
	if rune_id == "":
		rune_id = str(get_path())

	# Se já coletada, remove a runa
	if GameState.collected_runes.get(rune_id, false):
		queue_free()
		return

	message_text = "Pressione E para coletar"
	add_to_group("runas")
	super()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		_show_message(message_text)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		_hide_message()

func collect(player):
	if player.has_rune:
		_show_message("Não consigo carregar mais de uma...")
		return

	_hide_message() # esconde mensagem antes de coletar
	player.has_rune = true
	GameState.collected_runes[rune_id] = true

	if player.ui:
		player.ui.show_rune_icon()

	queue_free()

func reset():
	# Ex: reposicionar a runa, ativar sprite e colisão novamente
	visible = true
	collision_layer = 1
	collision_mask = 1
