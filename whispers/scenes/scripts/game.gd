extends Node2D

@onready var level_container = $Layer1/Level
@onready var player = $Layer1/Player
@onready var inventory = $Layer3/Inventory
@onready var color_rect = $Layer3/ColorRect
@onready var inventory_background = $Layer3/InventoryBackground
@onready var water = $Layer2/WaterMenuSound
@onready var effect_player = $Layer2/Effects/EffectsSound
@onready var breathing_player = $Layer2/Effects/Breathing
@onready var heartbeat_player = $Layer2/Effects/Heartbeat
@export var random_sounds : Array[AudioStream] = []

@export var water_volume_db := 3.0
@export var effects_volume_db := -10.0
@export var breathing_min_db := -40.0
@export var breathing_max_db := 0.0
@export var heartbeat_min_db := -35.0
@export var heartbeat_max_db := 0.0

# === Variáveis globais do batimento ===
var heartbeat_interval := 0.8  # segundos por batida (~75 BPM)
var heartbeat_timer := 0.0
var heartbeat_phase := 0.0


var inventory_open := false
var current_level_name := ""  # guarda o nome do nível atual

func _ready():
	load_level("res://Scenes/Levels/CT_map.tscn")
	
	# Conecta o sinal do player
	player.connect("request_inventory_toggle", Callable(self, "_on_player_request_inventory_toggle"))
	
	# inicia sons contínuos (mutados inicialmente)
	breathing_player.volume_db = breathing_min_db
	heartbeat_player.volume_db = heartbeat_min_db
	breathing_player.play()
	heartbeat_player.play()
	
func _process(delta):
	if not player:
		return

	update_breathing_sound()
	update_heartbeat_sound(delta)
	
func find_spawn(node: Node) -> Node2D:
	if node.name == "SpawnPoint":
		return node
	for child in node.get_children():
		var result = find_spawn(child)
		if result:
			return result
	return null

func load_level(path: String):
	# Remove nível antigo (se existir)
	for child in level_container.get_children():
		child.queue_free()
	
	# Carrega a nova cena
	var scene = load(path).instantiate()
	level_container.add_child(scene)

	# Guarda o nome do nível atual
	current_level_name = path.get_file().get_basename()  # ex: "CT_map"
	
	# Posiciona o player no ponto inicial (se houver um marcador na fase)
	var spawn = find_spawn(scene)
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector2.ZERO
	
	# Desativa Bubbles e WaterShade se não for CT_map
	if current_level_name != "CT_map":
		$Layer2/Bubbles.visible = true
		$Layer2/WaterShade.visible = true
		if current_level_name == "Atlantic_Map_Open":
			start_sounds()
		
	else:
		$Layer2/Bubbles.visible = false
		$Layer2/WaterShade.visible = false

func start_sounds():
	# aplica volumes
	water.volume_db = water_volume_db
	effect_player.volume_db = effects_volume_db
	
	# habilita loop no player
	if water.stream:
		water.stream.loop = true
		water.play()

	play_random_effect()

func play_random_effect():
	if random_sounds.is_empty():
		return

	var sound = random_sounds[randi() % random_sounds.size()]
	effect_player.stream = sound
	effect_player.play()

	var wait_time = randf_range(5.0, 15.0)
	await get_tree().create_timer(wait_time).timeout
	play_random_effect()
	
func _on_player_request_inventory_toggle():
	if current_level_name != "CT_map":
		return  # não abre inventário em outros mapas
	
	if inventory_open:
		close_inventory()
	else:
		open_inventory()
		
func pause_node_tree(node: Node):
	if node is Node2D or node is Control:
		node.set_process(false)
		node.set_physics_process(false)
		
	if node is AnimationPlayer:
		node.stop()
	if node is AnimatedSprite2D:
		node.speed_scale = 0
	if node is Timer:
		node.stop()  # pausa o Timer
	
	for child in node.get_children():
		pause_node_tree(child)
		
func unpause_node_tree(node: Node):
	if node is Node2D or node is Control:
		node.set_process(true)
		node.set_physics_process(true)
		
	if node is AnimationPlayer:
		node.play()
	if node is AnimatedSprite2D:
		node.speed_scale = 1
	if node is Timer:
		node.start()  # reinicia o Timer
	
	for child in node.get_children():
		unpause_node_tree(child)

func open_inventory():
	inventory_open = true
	
	# Pausa o Jogo
	pause_node_tree($Layer1/Level)
	pause_node_tree($Layer1/Player)
	pause_node_tree($Layer2/Bubbles)
	pause_node_tree($Layer2/Bubbles/BubbleSpawner)
	pause_node_tree($Layer2/WaterShade)

	# Mostra o fundo escuro e o inventário
	color_rect.modulate.a = 0
	inventory_background.modulate.a = 0
	color_rect.visible = true
	inventory_background.visible = true
	
	# Tween para fade-in do fundo
	var tween_bg = create_tween()
	tween_bg.set_trans(Tween.TRANS_BACK)
	tween_bg.set_ease(Tween.EASE_OUT)
	tween_bg.tween_property(color_rect, "modulate:a", 0.5, 0.6)
	tween_bg.tween_property(inventory_background, "modulate:a", 0.5, 0.6)
	await tween_bg.finished
	
	# Tween para animar o inventário
	var tween_inv = create_tween()
	tween_inv.set_trans(Tween.TRANS_BACK)
	tween_inv.set_ease(Tween.EASE_OUT)
	
	var viewport_center = get_viewport().get_visible_rect().size / 2
	var start_pos = viewport_center + Vector2(-200, 200)
	inventory.position = start_pos
	inventory.rotation_degrees = -30
	inventory.scale = Vector2(0.5, 0.5)
	inventory.visible = true
	
	tween_inv.tween_property(inventory, "position", viewport_center, 0.8)
	tween_inv.parallel().tween_property(inventory, "rotation_degrees", 0.0, 0.8)
	tween_inv.parallel().tween_property(inventory, "scale", Vector2.ONE, 0.8)
	await tween_inv.finished
	
	# Inventário já está na tela (viewport_center)
	var inventory_end_pos = get_viewport().get_visible_rect().size / 4

	# Botões começam atrás do inventário (à direita)
	var buttons = [inventory.save_tab, inventory.settings_tab]
	for b in buttons:
		var pos = b.position
		pos.x = inventory_end_pos.x
		pos.y = b.position.y            
		b.position = pos

	# Tween sequencial para os botões saindo para a esquerda
	var delay = 0.0
	for b in buttons:
		var tween_btn = create_tween()
		tween_btn.set_trans(Tween.TRANS_BACK)
		tween_btn.set_ease(Tween.EASE_OUT)
		
		var end_pos = Vector2(-b.get_size().x - 30, b.position.y)  # fora da tela à esquerda
		tween_btn.tween_interval(delay)
		tween_btn.tween_property(b, "position", end_pos, 0.5)
		
		delay += 0.1  # cada botão some 0.1s depois do anterior


func close_inventory():
	inventory_open = false
	
	var buttons = [inventory.save_tab, inventory.settings_tab]
	var delay = 0.0

	# Botões voltando atrás do inventário (à direita)
	for b in buttons:
		var tween_btn = create_tween()
		tween_btn.set_trans(Tween.TRANS_BACK)
		tween_btn.set_ease(Tween.EASE_IN)
		
		var inventory_end_pos = get_viewport().get_visible_rect().size / 4
		tween_btn.tween_interval(delay)
		tween_btn.tween_property(b, "position", inventory_end_pos, 0.4)
		
		delay += 0.1  # um de cada vez
		await tween_btn.finished
	
	# Tween do inventário e fade-out do fundo
	var tween_inv = create_tween()
	tween_inv.set_trans(Tween.TRANS_BACK)
	tween_inv.set_ease(Tween.EASE_IN)
	
	var end_inv_pos = Vector2(-200, get_viewport().get_visible_rect().size.y + 200)
	tween_inv.tween_property(inventory, "position", end_inv_pos, 0.6)
	tween_inv.parallel().tween_property(inventory, "rotation_degrees", -30, 0.6)
	tween_inv.parallel().tween_property(inventory, "scale", Vector2(0.5, 0.5), 0.6)
	tween_inv.tween_property(color_rect, "modulate:a", 0.0, 0.3)
	tween_inv.tween_property(inventory_background, "modulate:a", 0.0, 0.3)
	
	await tween_inv.finished
	
	# Esconde inventário e fundo
	inventory.visible = false
	color_rect.visible = false
	inventory_background.visible = true
	
	# Despausar nodes do jogo
	unpause_node_tree($Layer1/Level)
	unpause_node_tree($Layer1/Player)
	unpause_node_tree($Layer2/Bubbles)
	unpause_node_tree($Layer2/Bubbles/BubbleSpawner)
	unpause_node_tree($Layer2/WaterShade)

func update_breathing_sound():
	if not breathing_player.stream:
		return
	# Supondo que o oxigênio vai de 0 a 100
	var oxy = clamp(player.oxygen, 0, 100)
	# Quanto menor o oxigênio, mais alto o som
	var t = 1.0 - (oxy / 100.0)

	# Volume aumenta conforme o oxigênio diminui
	var volume = lerp(breathing_min_db, breathing_max_db, t)
	breathing_player.volume_db = volume

	# Pitch também aumenta (sensação de desespero)
	breathing_player.pitch_scale = lerp(1.0, 1.2, t)

func update_heartbeat_sound(delta):
	if not heartbeat_player.stream:
		return

	var sanity = clamp(player.sanity, 0, 100)
	var t = 1.0 - (sanity / 100.0)

	# Volume e pitch do coração
	var volume = lerp(heartbeat_min_db, heartbeat_max_db, t)
	heartbeat_player.volume_db = volume
	heartbeat_player.pitch_scale = lerp(1.0, 1.3, t)
	# Lê o volume atual do coração e reduz o volume dos efeitos conforme ele aumenta
	var heartbeat_db = heartbeat_player.volume_db
	var d = inverse_lerp(heartbeat_min_db, heartbeat_max_db, heartbeat_db)
	var volume_db = lerp(0.0, -25.0, d)  # -25dB no batimento máximo
	effect_player.volume_db = volume_db
	water.volume_db = volume_db

	# Intervalo entre batidas varia com a sanidade
	heartbeat_interval = lerp(1.2, 0.5, t)

	# Atualiza temporizador e fase
	heartbeat_timer += delta
	if heartbeat_timer >= heartbeat_interval:
		heartbeat_timer -= heartbeat_interval
		heartbeat_phase = 0.0
	else:
		heartbeat_phase = heartbeat_timer / heartbeat_interval

	# Pulso suave e sincronizado com o coração
	var pulse_value = pow(sin(heartbeat_phase * PI), 1)

	# === Atualiza shader da sanidade ===
	if player.sanity_shader:
		player.sanity_shader.set_shader_parameter("intensity", clamp(t * pulse_value/2, 0.0, 1.0))
		player.sanity_shader.set_shader_parameter("darken_factor", lerp(0.3, 0.9, t))
		player.sanity_shader.set_shader_parameter("pulse_value", pulse_value)
