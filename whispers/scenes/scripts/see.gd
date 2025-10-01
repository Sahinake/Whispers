extends Area2D

var player_inside := false
var start := false

@export var speed = 200
@onready var anim: AnimatedSprite2D = $Path2D/PathFollow2D/AnimatedSprite2D
@onready var path: PathFollow2D = $Path2D/PathFollow2D
@onready var hit_area: Area2D = $Path2D/PathFollow2D/AnimatedSprite2D/Hit 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	hit_area.body_entered.connect(_on_hit_entered)
	hit_area.monitoring = false  # começa desligada

func play() -> void:
	if player_inside:
		start = true
		anim.play("on")
		hit_area.monitoring = true  # ativa a área de dano quando começa o disparo
	else:
		start = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and path.progress_ratio == 0: # garante que é o jogador
		player_inside = true
		play()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _process(delta: float) -> void:
	if start == true and path.progress_ratio < 1:
		path.progress += speed * delta
	if path.progress_ratio == 1:
		anim.play("off")
		hit_area.monitoring = false  # desliga a área de dano quando terminou
		path.progress_ratio = 0
		if not player_inside:
			start = false
		play()
func _on_hit_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("💥 Player tomou dano do espinho!")
		if body.has_method("take_damage_trap"):
			body.take_damage_trap(-10)
