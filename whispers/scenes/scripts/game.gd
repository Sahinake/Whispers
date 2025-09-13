extends Node2D

@onready var level_container = $Layer1/Level
@onready var player = $Layer1/Player
@onready var inventory = $Layer3/Inventory
@onready var color_rect = $Layer3/ColorRect
@onready var inventory_background = $Layer3/InventoryBackground

var inventory_open := false

func _ready():
	load_level("res://Scenes/Levels/CT_map.tscn")
	
	# Conecta o sinal do player
	player.connect("request_inventory_toggle", Callable(self, "_on_player_request_inventory_toggle"))
	
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

	# Posiciona o player no ponto inicial (se houver um marcador na fase)
	var spawn = find_spawn(scene)
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector2.ZERO

func _on_player_request_inventory_toggle():
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
	var inventory_pos = inventory.position  # posição atual do inventário
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
