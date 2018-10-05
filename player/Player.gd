extends KinematicBody2D

export (int) var speed = 200
export (float) var fire_delay = 0.1

var envelope_scene

var velocity = Vector2()

func _ready():
	envelope_scene = preload("res://player/Envelope.tscn")
	
	$fire_timer.start()

func get_input():
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed('down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed('up'):
		velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	get_input()
	move_and_slide(velocity)

func fire_envelope():
	var envelope = envelope_scene.instance()
	#envelope.velocity = velocity
	envelope.position = $gun_position.global_position
	envelope.rotation = rotation
	get_parent().add_child(envelope)

func _on_fire_timer_timeout():
	fire_envelope()
	$fire_timer.start()
