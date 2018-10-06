extends KinematicBody2D

enum STATES {IDLE, WALKING}

export (int) var money_held = 10

var state
var speed = 100
var awareness = 1
var total_awareness = 1
var velocity = Vector2()

func _ready():
	change_state(IDLE)
	
	get_tree().current_scene.connect('update_awareness', self, '_on_Update_awareness')

func _process(delta):
	$ProgressBar.value = awareness
	$ProgressBar.max_value = total_awareness
	match state:
		IDLE:
			pass
		WALKING:
			pass

func _physics_process(delta):
	move_and_slide(velocity)

func change_state(new_state):
	state = new_state
	match new_state:
		WALKING:
			var direction = Vector2(randf()*2-1, randf()*2-1)
			look_at(direction + global_position)
			velocity = direction.normalized() * speed
			$ProgressBar.set_rotation(-rotation)
			$ProgressBar.rect_global_position = Vector2(global_position.x - $ProgressBar.rect_size.x/2, global_position.y - 50)
		IDLE:
			velocity = Vector2()
		
	$change_state_timer.wait_time = randi()%5+1
	$change_state_timer.start()

func _on_change_state_timer_timeout():
	if state == IDLE:
		change_state(WALKING)
	elif state == WALKING:
		change_state(IDLE)
		
func _on_Update_awareness(new_awareness):
	if new_awareness == 0:
		new_awareness = 1
	var percent = 1.0 if total_awareness == 0 else float(awareness) / total_awareness
	total_awareness = new_awareness
	awareness = percent * total_awareness
