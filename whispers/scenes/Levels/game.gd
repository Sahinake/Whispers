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
	
	for child in node.get_children():
		unpause_node_tree(child)

func open_inventory():
	inventory_open = true
	
	# Pausa o Jogo
	pause_node_tree($Layer1/Level)   # Pausa o mapa
	pause_node_tree($Layer1/Bubbles) # Pausa as bolhas
	pause_node_tree($Layer1/Player)  # Pausa o player se quiser
	pause_node_tree($Layer2/WaterShade) # Pausa o shader

	# Mostra o fundo escuro e o inventário
	color_rect.modulate.a = 0
	inventory_background.modulate.a = 0
	color_rect.visible = true
	inventory_background.visible = true
	
	# Tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	# Fade-in do ColorRect
	tween.tween_property(color_rect, "modulate:a", 0.5, 0.6)
	tween.tween_property(inventory_background, "modulate:a", 0.5, 0.6)
	
	await tween.finished
	
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_BACK)
	tween2.set_ease(Tween.EASE_OUT)
	
	# Inicializa posição e escala
	var end_pos = get_viewport().get_visible_rect().size / 2
	var start_pos = end_pos + Vector2(-200, 200)
	
	inventory.visible = true
	inventory.position = start_pos
	inventory.rotation_degrees = -30
	inventory.scale = Vector2(0.5, 0.5)
	
	tween2.tween_property(inventory, "position", end_pos, 0.8)
	tween2.parallel().tween_property(inventory, "rotation_degrees", 0.0, 0.8)
	tween2.parallel().tween_property(inventory, "scale", Vector2.ONE, 0.8)

func close_inventory():
	inventory_open = false
	
	var end_pos = Vector2(-200, get_viewport().get_visible_rect().size.y + 200)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	
	# Fade-out do ColorRect
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.6)
	tween.tween_property(inventory_background, "modulate:a", 0.0, 0.6)
	
	# Tween do inventário
	tween.tween_property(inventory, "position", end_pos, 0.6)
	tween.parallel().tween_property(inventory, "rotation_degrees", -30, 0.6)
	tween.parallel().tween_property(inventory, "scale", Vector2(0.5, 0.5), 0.6)
	
	await tween.finished
	inventory.visible = false
	color_rect.visible = false
	inventory_background.visible = true
	
	# Despausar nodes
	unpause_node_tree($Layer1/Level)
	unpause_node_tree($Layer1/Bubbles)
	unpause_node_tree($Layer1/Player)
	unpause_node_tree($Layer2/WaterShade)
