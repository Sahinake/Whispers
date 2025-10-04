extends PointLight2D

@onready var player: CharacterBody2D = $".."

var enemy = null

func  _physics_process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	if enemy:
		#for i in range(0, 66, 6):
		#	var ray =  global_position + Vector2(105, -30+i).rotated(rotation)
		var query = PhysicsRayQueryParameters2D.create(global_position, enemy.global_position)
				
		query.exclude = [self, player]
		var result = space_state.intersect_ray(query)
		if result && result.collider.is_in_group("enemies"):
			enemy.detection = true
		else:
			enemy.detection = false


func _on_flashlight_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemy = body


func _on_flashlight_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.detection = false
		enemy = null
