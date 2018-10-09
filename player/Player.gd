extends KinematicBody2D

signal spawn_envelope

enum STATES {IDLE, WALKING}

export (int) var speed = 200
export (float) var fire_delay = 0.1

export (int) var start_effectiveness = 50
export (int) var max_effectiveness = 100

export (NodePath) var camera_path
var camera

var state

var effectiveness

var velocity = Vector2()

func _ready():
	reset()
	
	if camera_path:
		camera = get_node(camera_path)
	else:
		print("ERROR: No camera path assigned to Player")
	
func reset():
	change_state(IDLE)
	
	effectiveness = start_effectiveness
	
	rotation = 0

func get_input():
	look_at(get_global_mouse_position())
	var move_dir = Vector2()
	if Input.is_action_pressed('down'):
		move_dir += Vector2(-1, 0)
	if Input.is_action_pressed('up'):
		move_dir += Vector2(1, 0)
	if Input.is_action_pressed('left'):
		move_dir += Vector2(0, -1)
	if Input.is_action_pressed('right'):
		move_dir += Vector2(0, 1)
	velocity = (move_dir.normalized() * speed).rotated(rotation)
		
	if Input.is_action_pressed('primary_action') and $fire_timer.is_stopped():
		emit_signal('spawn_envelope', $gun_position.global_position, rotation)
		$fire_timer.start()
		$Swoosh.play()

func change_state(new_state):
	state = new_state
	match new_state:
		WALKING:
			print('start walking')
			$AnimationPlayer.play("walk")
		IDLE:
			print('start idle')
			$AnimationPlayer.play("stand")

func _physics_process(delta):
	get_input()
	move_and_slide(velocity)
	
	position.x = clamp(position.x, camera.limit_left, camera.limit_right)
	position.y = clamp(position.y, camera.limit_top, camera.limit_bottom)
	
	match state:
		IDLE:
			if velocity.length() != 0:
				change_state(WALKING)
		WALKING:
			if velocity.length() == 0:
				change_state(IDLE)
