extends "res://Scenes/Scripts/interactiveArea.gd"

func _ready():
	message_text = "Pressione ENTER para interagir"
	super()

func _process(delta):
	super(delta)

	if player_inside and Input.is_action_just_pressed("ui_accept"):
		_hide_message()   # mata texto e tween
		await get_tree().process_frame  # garante limpeza visual
		var game = get_tree().current_scene
		game.load_level("res://Scenes/Levels/Level_One.tscn")
