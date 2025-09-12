extends Control

@onready var music = $MusicMenuSound
@onready var water = $WaterMenuSound
@onready var effect_player = $Effects/EffectsSound
@onready var ui_sound = $UISound
@onready var select_sound = $SelectSound

@export var random_sounds : Array[AudioStream] = []

@export var music_volume_db := 1.0  
@export var water_volume_db := 3.0   
@export var effects_volume_db := -0.5

var current_button : Button = null

func _ready():
	var buttons = $VBoxContainer.get_children()
	for b in buttons:
		if b is Button:
			b.focus_mode = Control.FOCUS_ALL
			b.add_theme_color_override("font_color", Color(1,1,1))
			b.add_theme_color_override("font_color_hover", Color(0.9,0.9,1))
			b.add_theme_color_override("font_color_focus", Color(1,1,0.8))
			# conecta sinal com argumento
			b.focus_entered.connect(Callable(self, "_on_button_focus").bind(b))
			b.pressed.connect(_on_button_pressed)
	
	# força foco no primeiro botão
	for b in buttons:
		if b is Button:
			current_button = b
			b.grab_focus()
			break

	# aplica volumes
	music.volume_db = music_volume_db
	water.volume_db = water_volume_db
	effect_player.volume_db = effects_volume_db
	ui_sound.volume_db = effects_volume_db
	select_sound.volume_db = effects_volume_db

	# música e água
	if music.stream:
		music.stream.loop = true
		music.play()
	if water.stream:
		water.stream.loop = true
		water.play()

	play_random_effect()

# === som de foco ===
func _on_button_focus(button):
	if button != current_button:
		current_button = button
		if ui_sound and ui_sound.stream:
			ui_sound.play()

# som de seleção e ação
func _on_button_pressed():
	if select_sound and select_sound.stream:
		select_sound.play()

	var b = current_button

	# se for NewGameButton, espera o som tocar antes de mudar
	if b == $VBoxContainer/NewGameButton:
		if select_sound.stream:
			# aguarda o som tocar
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
			await fade_out_menu(1.0)
			get_tree().change_scene_to_file("res://Scenes/Game.tscn")

	elif b == $VBoxContainer/LoadGameButton:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		print("Carregar jogo ainda não implementado")

	elif b == $VBoxContainer/Settings:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		print("Abrir menu de configurações")

	elif b == $VBoxContainer/Exit:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		get_tree().quit()

func play_random_effect():
	if random_sounds.is_empty():
		return

	var sound = random_sounds[randi() % random_sounds.size()]
	effect_player.stream = sound
	effect_player.play()

	var wait_time = randf_range(5.0, 15.0)
	await get_tree().create_timer(wait_time).timeout
	play_random_effect()

func fade_out_menu(duration := 0.5) -> void:
	var fade_rect = $FadeOverlay
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration) # aumenta alpha para 1
	await tween.finished
