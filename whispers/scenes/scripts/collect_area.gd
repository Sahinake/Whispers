extends Area2D

@export var energy_amount := 20.0  # quanto aumenta a lanterna

func _ready():
	add_to_group("energic_algae")
	# Conecta sinais opcionais se quiser detectar entrada/saída do player
	body_entered.connect(Callable(self, "_on_body_entered"))
	body_exited.connect(Callable(self, "_on_body_exited"))

var player_in_area: CharacterBody2D = null

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body

func _on_body_exited(body):
	if body == player_in_area:
		player_in_area = null

# Função chamada pelo player quando aperta E
func collect_flashlight(player: CharacterBody2D):
	player.change_flashlight(energy_amount)
	queue_free()  # remove a alga da cena
