extends PointLight2D

var enemy = null

func  _process(delta: float) -> void:
	if enemy:
		color = Color(1,0,0)
	else:
		color = Color(1,1,1)
	
	


func _on_light_area_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
		enemy = body


func _on_light_area_body_exited(body: Node2D) -> void:
	if body.name == "enemy":
		enemy = null
