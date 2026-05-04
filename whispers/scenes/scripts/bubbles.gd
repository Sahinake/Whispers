extends Node2D

@export var bubble_scene: PackedScene
@export var spawn_interval := 1.0

@onready var timer: Timer = $BubbleSpawner

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_bubble)
	timer.start()

func _spawn_bubble():
	# só spawn se bubble_scene estiver definido e Node visível (Level_One)
	if bubble_scene == null:
		return
	if not is_visible_in_tree():
		return
	
	var bubble = bubble_scene.instantiate()
	# frame aleatório
	bubble.start_frame = randi() % bubble.sprite_frames.get_frame_count(bubble.animation_name)
	# spawn em x aleatório dentro da tela
	var viewport_size = get_viewport_rect().size
	bubble.global_position.x = randf_range(0, viewport_size.x)
	# spawn logo abaixo da tela
	bubble.global_position.y = viewport_size.y + randf_range(10, 40)
	add_child(bubble)
