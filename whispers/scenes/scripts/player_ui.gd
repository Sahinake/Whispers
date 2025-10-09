extends CanvasLayer

@onready var oxygen_bar = $OxygenBar
@onready var sanity_bar = $SanityBar
@onready var flashlight_bar = $FlashlightBar

@onready var rune_icon = $RuneIcon  # coloque o caminho correto

# Atualiza a UI com os valores recebidos do jogador
func update_ui(oxygen: float, sanity: float, flashlight: float) -> void:
	# Oxigênio: vermelho -> verde
	oxygen_bar.value = oxygen

	# Sanidade: vermelho -> azul
	sanity_bar.value = sanity

	# Lanterna: branco -> azul
	flashlight_bar.value = flashlight

func show_rune_icon():
	rune_icon.visible = true
