extends Area2D

var player_inside = false
var fade_speed := 2.0  # Velocidade do fade
@onready var message_label = get_tree().root.get_node("Game/PlayerUI/MessageLabel") 


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	message_label.modulate.a = 0.0  # Invisível no início

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false

func _process(delta):
	# Fade in/out suave
	var target_alpha = 1.0 if player_inside else 0.0
	message_label.modulate.a = lerp(message_label.modulate.a, target_alpha, delta * fade_speed * 2)
	
	if player_inside and Input.is_action_just_pressed("ui_accept"):
		var game = get_tree().current_scene
		game.load_level("res://Scenes/Levels/Level_One.tscn")
