extends Area2D

func collect(player):
	player.has_rune = true  # Marca que o jogador pegou a runa
	
	# Atualiza a UI para mostrar o ícone
	if player.ui:
		player.ui.show_rune_icon()
	
	queue_free()
