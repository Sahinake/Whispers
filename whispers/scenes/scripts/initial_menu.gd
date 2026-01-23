extends Control

@onready var music = $MusicMenuSound
@onready var water = $WaterMenuSound
@onready var effect_player = $Effects/EffectsSound
@onready var ui_sound = $UISound
@onready var select_sound = $SelectSound

@export var random_sounds : Array[AudioStream] = []

@export var music_volume_db := 0.0  
@export var water_volume_db := 2.0   
@export var effects_volume_db := 10.0

var showing_controls := false
var current_button : Button = null
var intro_skipped := false
var intro_running := true

# =========================
# UI
# =========================
@onready var canvas_layer : CanvasLayer = $CanvasLayer
@onready var menu_container : VBoxContainer = $VBoxContainer
@onready var config_container : VBoxContainer = $HowToPlayPanel/VBoxContainer
@onready var fade_rect : ColorRect = $FadeOverlay
@onready var intro_label : Label = $IntroLabel

@onready var how_to_play_panel : Control = $HowToPlayPanel
@onready var how_to_play_label : RichTextLabel = $HowToPlayPanel/RichTextLabel
@onready var how_to_play_back_button : Button = $HowToPlayPanel/VBoxContainer/Voltar
@onready var how_to_play_back_button_controles : Button = $HowToPlayPanel/VBoxContainer/Controles

func _ready():
	# ESCONDE TUDO DO MENU
	canvas_layer.visible = false
	how_to_play_panel.visible = false
	
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 1)
	
	# intro label invisível
	intro_label.visible = false
	intro_label.modulate.a = 0.0

	# prepara botões (mesmo invisíveis)
	var buttons = menu_container.get_children()
	for b in buttons:
		if b is Button:
			b.focus_mode = Control.FOCUS_ALL
			b.focus_entered.connect(Callable(self, "_on_button_focus").bind(b))
			b.pressed.connect(_on_button_pressed)
			
	var buttons_config = config_container.get_children()
	for bc in buttons_config:
		if bc is Button:
			bc.focus_mode = Control.FOCUS_ALL
			bc.focus_entered.connect(Callable(self, "_on_button_focus").bind(bc))
			bc.pressed.connect(_on_button_pressed)
	
	if GameState.skip_intro:
		GameState.skip_intro = false
		show_menu_directly()
	else:
		# áudio (pode começar antes)
		setup_audio()

		play_random_effect()
		await play_intro()

	# MOSTRA TUDO DE UMA VEZ
	canvas_layer.visible = true
	
	# agora tira o fade
	await fade_in_menu(1.0)
	
	# foco no primeiro botão
	for b in buttons:
		if b is Button:
			current_button = b
			b.grab_focus()
			break

	play_random_effect()

# som de foco
func _on_button_focus(button):
	if button != current_button:
		current_button = button
		if ui_sound and ui_sound.stream:
			ui_sound.play()

# =========================
# INTRO
# =========================
func setup_audio():
	music.volume_db = music_volume_db
	water.volume_db = water_volume_db
	effect_player.volume_db = effects_volume_db
	ui_sound.volume_db = effects_volume_db
	select_sound.volume_db = -30.0

	if music.stream:
		music.stream.loop = true
		music.play()
	if water.stream:
		water.stream.loop = true
		water.play()

func show_menu_directly():
	intro_label.visible = false
	menu_container.visible = true
	set_initial_focus()

func set_initial_focus():
	if not menu_container.visible:
		return

	var buttons = menu_container.get_children()
	for b in buttons:
		if b is Button:
			current_button = b
			b.grab_focus()
			break

func play_intro():
	intro_running = true

	# ===== MENSAGEM 1 =====
	intro_label.text = "Para uma melhor experiência,\nuse fones de ouvido."
	await fade_in_label(1.0)
	await wait_or_skip(2.0)
	await fade_out_label(0.5)

	await wait_or_skip(0.3)

	# ===== MENSAGEM 2 =====
	intro_label.text = "Sussurros é apenas uma demo.\nA experiência completa ainda está por vir..."
	await fade_in_label(1.0)
	await wait_or_skip(2.5)
	await fade_out_label(0.5)

	intro_running = false
	# mantém fade preto

# =========================
# FADES
# =========================
func fade_in_menu(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished


func fade_out_menu(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished


func fade_in_label(duration := 1.0):
	intro_label.visible = true
	intro_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(intro_label, "modulate:a", 1.0, duration)
	await tween.finished

func fade_out_label(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(intro_label, "modulate:a", 0.0, duration)
	await tween.finished
	intro_label.visible = false
	
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

	elif b == $VBoxContainer/ComoJogar:
		await wait_select_sound()
		open_how_to_play()

	elif b == $VBoxContainer/Settings:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		print("Abrir menu de configurações")

	elif b == $VBoxContainer/Exit:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		get_tree().quit()
		
	elif b == $HowToPlayPanel/VBoxContainer/Controles:
		if select_sound.stream:
				await get_tree().create_timer(select_sound.stream.get_length()).timeout
		_on_controls_button_pressed()
	elif b == $HowToPlayPanel/VBoxContainer/Voltar:
		if select_sound.stream:
			await get_tree().create_timer(select_sound.stream.get_length()).timeout
		_on_how_to_play_back()

func play_random_effect():
	if random_sounds.is_empty():
		return

	var sound = random_sounds[randi() % random_sounds.size()]
	effect_player.stream = sound
	effect_player.play()

	var wait_time = randf_range(5.0, 15.0)
	await get_tree().create_timer(wait_time).timeout
	play_random_effect()
	
func open_how_to_play():
	menu_container.visible = false
	how_to_play_panel.visible = true

	set_how_to_play_text()
	how_to_play_back_button_controles.text = "CONTROLES"

	how_to_play_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	how_to_play_back_button_controles.grab_focus()

	if select_sound and select_sound.stream:
		select_sound.play()

func set_how_to_play_text():
	how_to_play_label.text = """
	[center]
	[font_size=54]COMO JOGAR[/font_size]

	[font_size=22]
	Sussurros é uma experiência narrativa e atmosférica.
	Explore o ambiente em busca de Runas, ouça atentamente,
	escape de armadilhas e evite os inimigos à espreita.
	[/font_size]

	[font_size=48]OBJETIVO DA DEMO[/font_size]
	[font_size=22]
	Coletar as 3 Runas e ativar o portal.
	[/font_size]
	[/center]
	"""
	showing_controls = false

func set_controls_text():
	how_to_play_label.text = """
	[center][font_size=54]CONTROLES[/font_size][/center]
	[table=1][cell][left][font_size=22]
	• WASD – Movimentar
	• Mouse – Olhar ao redor
	• T – Ligar/Desligar a lanterna
	• E – Interagir com objetos
	• SHIFT - Correr
	• ENTER – Interagir com Entradas/Saídas
	• ESC – Pausar / Voltar
	[/font_size][/left][/cell][/table]
	"""
	showing_controls = true

func _on_controls_button_pressed():
	if showing_controls:
		set_how_to_play_text()
		how_to_play_back_button_controles.text = "CONTROLES"
	else:
		set_controls_text()
		how_to_play_back_button_controles.text = "COMO JOGAR"

func _on_how_to_play_back():
	how_to_play_panel.visible = false
	menu_container.visible = true

	# devolve foco ao menu
	current_button = $VBoxContainer/NewGameButton
	current_button.grab_focus()

func _unhandled_input(event):
	if intro_running and event.is_action_pressed("ui_accept"):
		intro_skipped = true

	if how_to_play_panel.visible and event.is_action_pressed("ui_cancel"):
		_on_how_to_play_back()
		
func wait_or_skip(time: float) -> void:
	intro_skipped = false
	var timer = get_tree().create_timer(time)

	while timer.time_left > 0:
		if intro_skipped:
			break
		await get_tree().process_frame


func wait_select_sound():
	if select_sound and select_sound.stream:
		await get_tree().create_timer(select_sound.stream.get_length()).timeout
