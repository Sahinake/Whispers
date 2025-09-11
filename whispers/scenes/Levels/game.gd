extends Node2D

@onready var level_container = $Layer1/Level
@onready var player = $Layer1/Player

func _ready():
	load_level("res://Scenes/Levels/CT_map.tscn")
	
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
