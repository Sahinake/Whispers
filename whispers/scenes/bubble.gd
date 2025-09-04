extends AnimatedSprite2D

@export var camera: Camera2D 
@export var speed := 40.0
@export var amplitude := 20.0     		 	# o quanto a bolha se desloca pro lado
@export var frequency := 2.0       			# quão rápido ela oscila
@export var animation_name := "bubbles"   	# nome da animação no editor
var map_top := 0   							# topo do mapa

var base_x := 0.0
var time_passed := 0.0

func _ready():
	# Pega a câmera principal da cena
	var camera = get_tree().get_root().get_node("MainScene/Camera2D")
	
	if camera == null:
		push_error("Nenhuma câmera encontrada!")
		return
		
	if sprite_frames and sprite_frames.has_animation(animation_name):
		animation = animation_name   # garante que estamos na animação correta
		var total_frames = sprite_frames.get_frame_count(animation_name)
		if total_frames > 0:
			print(total_frames)
			frame = randi() % total_frames  # escolhe um frame alaeatório
	
	var viewport_size = get_viewport_rect().size * 2
	
	# Spawn Y logo abaixo da visão da câmera
	global_position.y = camera.global_position.y + viewport_size.y / 2 + randf_range(10, 40)
	
	# Define X inicial aleatório dentro da visão da câmera
	var left = camera.global_position.x - viewport_size.x
	var right = camera.global_position.x + viewport_size.x
	global_position.x = randf_range(left, right)
	
	base_x = global_position.x   # salva posição inicial no eixo X
	scale = Vector2.ONE * randf_range(0.5, 1.5)
	modulate.a = randf_range(0.6, 1.0)

func _process(delta):
	time_passed += delta

	# sobe no Y
	global_position.y -= speed * delta
	
	# oscila no X
	global_position.x = base_x + sin(time_passed * frequency) * amplitude

	# Remove bolha ao passar da parte de cima da tela
	var camera = get_tree().get_root().get_node("MainScene/Camera2D")
	
	# remove bolha quando passar do topo do mapa
	if global_position.y < map_top:
		queue_free()
