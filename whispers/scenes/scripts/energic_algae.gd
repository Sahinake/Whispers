extends "res://Scenes/Scripts/interactiveArea.gd"

@export var energy_amount := 20.0
var algae_id := ""  # ID único para cada alga

func _ready():
	message_text = "Pressione E para coletar"
	super()
	
	# gera ID automático usando o path do nó
	algae_id = str(get_path())
	
	# Só adiciona se ainda não coletado 
	if GameState.collected_algae.get(algae_id, false): 
		queue_free()
		
func _process(delta):
	super(delta)

	if player_inside and Input.is_action_just_pressed("interact"):
		var player = get_overlapping_bodies()[0]
		collect(player)

func collect(player):
	_hide_message()
	player.change_flashlight(energy_amount)
	
	# salva no GameState
	GameState.collected_algae[algae_id] = true

	queue_free()
