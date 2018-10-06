extends KinematicBody2D

signal spawn_envelope

export (int) var speed = 200
export (float) var fire_delay = 0.1

var velocity = Vector2()

func _ready():
	pass

func get_input():
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed('down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed('up'):
		velocity = Vector2(speed, 0).rotated(rotation)
		
	if Input.is_action_pressed('primary_action') and $fire_timer.is_stopped():
		emit_signal('spawn_envelope', $gun_position.global_position, rotation)
		$fire_timer.start()

func _physics_process(delta):
	get_input()
	move_and_slide(velocity)
