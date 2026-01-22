extends Area2D

@export var message_text := ""
@export var screen_margin := 25.0
@export var is_altar := false 

var player_inside := false
var fade_tween: Tween
var label_tween: Tween = null
var altar_tween: Tween = null

@onready var message_label := get_tree().root.get_node("Game/PlayerUI/MessageLabel")
@onready var altar_card := get_tree().root.get_node("Game/PlayerUI/AltarCard")
@onready var message_label_altar := altar_card.get_node("MessageLabelAltar")

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

	_setup_label(message_label)
	_setup_label(message_label_altar)
	
	message_label.modulate.a = 0.0
	altar_card.modulate.a = 0.0
	message_label_altar.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label_altar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _process(delta):
	pass
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_inside = true

		if is_altar:
			_show_altar_message(message_text)
		else:
			_show_message(message_text)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false
		_hide_message()
		
func _setup_label(label: Label):
	if not label:
		return

	label.modulate = Color.WHITE
	label.add_theme_color_override("font_color", Color.WHITE)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
func _fade_in():
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.25
	)

func _fade_out():
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		message_label,
		"modulate:a",
		0.0,
		0.25
	)

func _show_message(text: String):
	if not message_label:
		return

	message_label.text = text
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	message_label.modulate.a = 1.0
	_adjust_label_position()

	_start_message_tween(message_label)
	
func _show_altar_message(text: String):
	if not altar_card:
		return

	message_label_altar.text = text
	message_label_altar.autowrap_mode = TextServer.AUTOWRAP_WORD

	# centraliza dentro do card
	message_label_altar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label_altar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# mostra o card com fade
	altar_card.modulate.a = 1.0
	_start_card_tween()
	
func _start_card_tween():
	var stay_time := 4.0
	var fade_time := 0.5

	if altar_tween:
		altar_tween.kill()

	altar_tween = create_tween()
	altar_tween.tween_interval(stay_time)
	altar_tween.tween_property(altar_card, "modulate:a", 0.0, fade_time)

func _start_message_tween(label: Label):
	var stay_time := 4.0
	var fade_time := 0.5

	if label_tween:
		label_tween.kill()

	label_tween = create_tween()
	label_tween.tween_interval(stay_time)
	label_tween.tween_property(label, "modulate:a", 0.0, fade_time)

# ===============================
# Esconder tudo
# ===============================
func _hide_message():
	if label_tween:
		label_tween.kill()
		label_tween = null

	if altar_tween:
		altar_tween.kill()
		altar_tween = null

	if message_label:
		message_label.modulate.a = 0.0
		message_label.text = ""

	if altar_card:
		altar_card.modulate.a = 0.0


# ===============================
# Posições
# ===============================
func _adjust_label_altar_position():
	var viewport_size := get_viewport_rect().size

	# largura máxima do card
	var max_width := viewport_size.x * 0.4
	altar_card.custom_minimum_size.x = max_width

	# força o Godot a recalcular o tamanho real da label
	message_label_altar.queue_redraw()
	await get_tree().process_frame

	# ancora o card no canto superior direito com margem
	altar_card.position.x = viewport_size.x - altar_card.size.x - screen_margin
	altar_card.position.y = screen_margin

func _adjust_label_position():
	var viewport_size := get_viewport_rect().size
	var max_width := viewport_size.x * 0.5

	message_label.custom_minimum_size.x = max_width
	message_label.position.x = viewport_size.x - max_width - screen_margin
	message_label.position.y = viewport_size.y - message_label.size.y - screen_margin
