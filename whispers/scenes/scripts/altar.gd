extends "res://Scenes/Scripts/interactiveArea.gd"

@onready var sprite: AnimatedSprite2D = $"../Altar2"
@onready var putting_rune: AudioStreamPlayer2D = $"../PuttingRuna"
@export var total_runes := 3
@export var end_delay := 5.0

var interaction_locked := false

# ===============================
# Ready
# ===============================
func _ready():
	add_to_group("altar")
	super()

	# Restaura estado
	if GameState.altar_activated:
		_play_if_exists("activated")

# ===============================
# Interação com o Player
# ===============================
func try_activate(player):
	if GameState.altar_activated or interaction_locked:
		return

	if not player.has_rune:
		_show_altar_message("Você sente que falta algo aqui...")
		return

	interaction_locked = true
	player.deliver_rune()

	GameState.deposited_runes += 1
	putting_rune.play()

	match GameState.deposited_runes:
		1:
			_play_if_exists("default")
			_show_altar_message("A primeira runa se encaixa... o altar reage suavemente.")

		2:
			_play_if_exists("default")
			_show_altar_message("O altar começa a pulsar. Algo observa.")

		3:
			_play_if_exists("activated")
			_show_altar_message("As runas entram em ressonância. O altar finalmente desperta.")
			GameState.altar_activated = true
			await _finish_altar()
			return

	await get_tree().create_timer(0.6).timeout
	interaction_locked = false



func _play_if_exists(anim_name: String):
	
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

# ===============================
# Finalização do jogo
# ===============================
func _finish_altar():
	await get_tree().create_timer(end_delay).timeout
	get_tree().change_scene_to_file("res://Scenes/WonScene.tscn")

# ===============================
# Mensagens na UI
# ===============================
func _show_message(text: String):
	if not message_label:
		return

	message_label.text = text
	message_label.modulate.a = 1.0
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_adjust_label_position()

	var stay_time := 4.0   # tempo totalmente visível
	var fade_time := 0.6   # tempo do fade

	var tween = create_tween()
	tween.tween_interval(stay_time)
	tween.tween_property(message_label, "modulate:a", 0.0, fade_time)

func _adjust_label_position():
	var viewport_size := get_viewport_rect().size

	# largura máxima do texto (50% da tela)
	var max_width := viewport_size.x * 0.5
	message_label.custom_minimum_size.x = max_width

	# canto inferior direito com margem
	message_label.position.x = viewport_size.x - max_width - screen_margin
	message_label.position.y = viewport_size.y - message_label.size.y - screen_margin
