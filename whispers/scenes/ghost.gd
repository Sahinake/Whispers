extends CharacterBody2D

@export var target_to_chase : CharacterBody2D
@export var speed: float = 250.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var path_update: Timer = $PathUpdate
@onready var detection: bool = false
@onready var can_attack: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("arise")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
