extends "res://Scenes/Scripts/interactiveArea.gd"

@export var energy_amount := 20.0

func _ready():
	message_text = "Pressione E para coletar"
	super()

func _process(delta):
	super(delta)

	if player_inside and Input.is_action_just_pressed("interact"):
		var player = get_overlapping_bodies()[0]
		collect(player)

func collect(player):
	_hide_message()
	player.change_flashlight(energy_amount)
	queue_free()
