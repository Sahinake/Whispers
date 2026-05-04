extends AnimatedSprite2D

@export var speed := 40.0
@export var amplitude := 20.0
@export var frequency := 2.0
@export var animation_name := "bubbles"
@export var map_top := -50  # topo da tela para sumir

var base_x := 0.0
var time_passed := 0.0
var start_frame: int = -1

func _ready():
	# animação
	if sprite_frames and sprite_frames.has_animation(animation_name):
		animation = animation_name
		var total_frames = sprite_frames.get_frame_count(animation_name)
		if total_frames > 0:
			if start_frame >= 0 and start_frame < total_frames:
				frame = start_frame
			else:
				frame = randi() % total_frames
	
	base_x = global_position.x - 400
	scale = Vector2.ONE * randf_range(0.5, 1.5)
	modulate.a = randf_range(0.6, 1.0)

func _process(delta):
	time_passed += delta
	
	# sobe no Y
	global_position.y -= speed * delta
	
	# movimento lateral
	global_position.x = base_x + sin(time_passed * frequency) * amplitude \
							   + sin(time_passed * frequency * 0.5) * (amplitude * 0.5)
	
	# pequena rotação
	rotation = sin(time_passed * frequency * 1.2) * 0.1
	
	# remove bolha ao passar do topo
	if global_position.y < map_top:
		queue_free()
