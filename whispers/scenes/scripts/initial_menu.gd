extends Control

@onready var music = $MusicMenuSound
@onready var water = $WaterMenuSound
@onready var effect_player = $Effects/EffectsSound

# Sons aleatórios (sussurros, animais marinhos, etc.)
@export var random_sounds : Array[AudioStream] = []

# Volumes (em decibéis)
@export var music_volume_db := 1.0  
@export var water_volume_db := 3.0   
@export var effects_volume_db := - 0.5

func _ready():
	# conecta botões
	var newGameBtn = $VBoxContainer/NewGameButton
	if newGameBtn:
		newGameBtn.pressed.connect(_on_novo_jogo_pressed)

	var loadGameButton = $VBoxContainer/LoadGameButton
	if loadGameButton:
		loadGameButton.pressed.connect(_on_carregar_jogo_pressed)

	var settingsButton = $VBoxContainer/Settings
	if settingsButton:
		settingsButton.pressed.connect(_on_configuracoes_pressed)

	var exitButton = $VBoxContainer/Exit
	if exitButton:
		exitButton.pressed.connect(_on_sair_pressed)

	# aplica volumes
	music.volume_db = music_volume_db
	water.volume_db = water_volume_db
	effect_player.volume_db = effects_volume_db

	# inicia música e água em loop
	if music.stream:
		music.stream.loop = true
		music.play()

	if water.stream:
		water.stream.loop = true
		water.play()

	# inicia ciclo de sons aleatórios
	play_random_effect()

func play_random_effect():
	if random_sounds.is_empty():
		return

	# escolhe som aleatório
	var sound = random_sounds[randi() % random_sounds.size()]
	effect_player.stream = sound
	effect_player.play()

	# agenda próximo efeito em intervalo randômico
	var wait_time = randf_range(5.0, 15.0) # ajusta intervalo aqui
	await get_tree().create_timer(wait_time).timeout
	play_random_effect()

# ==== Botões do menu ====
func _on_novo_jogo_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_carregar_jogo_pressed():
	print("Carregar jogo ainda não implementado")

func _on_configuracoes_pressed():
	print("Abrir menu de configurações")

func _on_sair_pressed():
	get_tree().quit()
