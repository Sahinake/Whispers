extends "res://Scenes/Scripts/interactiveArea.gd"

@export var target_scene := "res://Scenes/Levels/CT_map.tscn"

func _ready():
	message_text = "Pressione ENTER para interagir"
	super()

func _process(delta):
	super(delta)

	if player_inside and Input.is_action_just_pressed("ui_accept"):
		_hide_message()                 # remove texto + mata tween
		await get_tree().process_frame  # garante limpeza no frame
		var game = get_tree().current_scene
		game.load_level(target_scene)
