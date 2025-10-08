extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/FadeOver
@onready var game_over_label: Label = $CanvasLayer/GameOverLabel
@onready var game_over_sound: AudioStreamPlayer = $CanvasLayer/GameOverSound

var fade_duration := 1.0
var waiting_input := false

func _ready():
	# Inicializa fade preto transparente
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.visible = true
	
	# Label inicialmente invisível
	game_over_label.visible = false
	
	# Mostra Game Over
	show_game_over()

func show_game_over():
	# Mostra label
	game_over_label.visible = true
	
	# Toca som de Game Over
	if game_over_sound:
		game_over_sound.play()
	
	# Espera input
	waiting_input = true

func _process(delta):
	if waiting_input and Input.is_action_just_pressed("ui_accept"):
		waiting_input = false
		start_fade_to_menu()

func start_fade_to_menu():
	# Faz fade para preto
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	tween.tween_callback(Callable(self, "_go_to_menu"))

func _go_to_menu():
	# Troca para a cena do menu principal
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
