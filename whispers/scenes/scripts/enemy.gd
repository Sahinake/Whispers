extends CharacterBody2D

@export var target_to_chase : CharacterBody2D

@onready var nav_chase : NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer
@onready var detect_light: Area2D = $detect_light
@onready var luz : PointLight2D

var speed =  70
var dir
var start_pos
var detection: bool = false

enum State{IDLE, CHASE, BACK, ATTACK}

var current_state : State 

func _ready() -> void:
	start_pos = global_position
	dir = Vector2.ZERO
	current_state = State.IDLE
	luz = target_to_chase.get_node("light")
	luz.enemy_spotted.connect(_on_light_detect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if nav_chase.is_navigation_finished() && target_to_chase.global_position == nav_chase.target_position:
		return
	match current_state:
		State.IDLE:
			if detection:
				current_state = State.CHASE
			velocity = Vector2.ZERO
		State.CHASE:
			var dist = (target_to_chase.global_position - global_position).length()
			if !detection && dist > 200:
				current_state = State.BACK
			dir = to_local(nav_chase.get_next_path_position()).normalized()
			velocity = dir *speed
		State.BACK:
			if detection:
				current_state = State.CHASE
			elif nav_chase.is_navigation_finished() && target_to_chase.global_position == nav_chase.target_position:
				current_state = State.IDLE
			dir = to_local(nav_chase.get_next_path_position()).normalized()
			velocity = dir *speed
	move_and_slide()
	
	
func movement():
	if current_state == State.CHASE:
		nav_chase.target_position = target_to_chase.global_position
	elif current_state == State.BACK:
		nav_chase.target_position = start_pos
		

func _on_light_detect(light):
	detection = light
			
			
func _on_timer_timeout() -> void:
	if current_state != State.IDLE:
		movement()
