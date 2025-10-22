extends Area2D

@export var energy_amount := 20.0  # quanto aumenta a lanterna

func collect(player):
	# Aumenta a lanterna do player
	player.change_flashlight(energy_amount)
	# Remove a alga da cena
	queue_free()
