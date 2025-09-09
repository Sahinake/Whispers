extends CharacterBody2D

@export var target_to_chase : CharacterBody2D

@onready var nav_chase : NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer
@onready var detect_light: Area2D = $detect_light
@onready var luz : Area2D = null

var speed =  70
var dir
var start_pos

enum State{IDLE, CHASE, BACK}

var current_state : State 

func _ready() -> void:
	start_pos = global_position
	dir = Vector2.ZERO
	current_state = State.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if nav_chase.is_navigation_finished() && target_to_chase.global_position == nav_chase.target_position:
		return
	match current_state:
		State.IDLE:
			if light_detect(luz):
				current_state = State.CHASE
			velocity = Vector2.ZERO
		State.CHASE:
			var dist = (target_to_chase.global_position - global_position).length()
			if !light_detect(luz) && dist > 200:
				current_state = State.BACK
			dir = to_local(nav_chase.get_next_path_position()).normalized()
			velocity = dir *speed
		State.BACK:
			if light_detect(luz):
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
		

func light_detect(light):
		if light:
			return true
		else:
			return false
			
			
func _on_timer_timeout() -> void:
	if current_state != State.IDLE:
		movement()


func _on_detect_light_area_entered(area: Area2D) -> void:
	if area.name == "lightArea":
		luz = area


func _on_detect_light_area_exited(area: Area2D) -> void:
	if area.name == "lightArea":
		luz = null
