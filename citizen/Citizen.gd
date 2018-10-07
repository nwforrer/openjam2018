extends KinematicBody2D

enum STATES {IDLE, WALKING, FLEEING, RETURNING}

export (int) var money_held = 10
export (int) var flee_distance = 200
export (NodePath) var player_path

var show_states = false

var player
var state
var speed
var walk_speed = 100
var run_speed = 300
var awareness = 1
var total_awareness = 1
var velocity = Vector2()

var home_area

func _ready():
	change_state(IDLE)
	
	get_tree().current_scene.connect('update_awareness', self, '_on_Update_awareness')
	
	if get_parent().is_class('Area2D'):
		home_area = get_parent()
	else:
		print('WARNING: No home area for ', name)
		
	if player_path:
		player = get_node(player_path)
	else:
		print('ERROR: Player not assigned to ', name)

func _process(delta):
	$Overhead/ProgressBar.value = awareness
	$Overhead/ProgressBar.max_value = total_awareness
	
	check_to_flee()
			
	match state:
		IDLE:
			pass
		WALKING:
			if home_area:
				if not home_area.overlaps_body(self):
					var direction = home_area.global_position - global_position
					set_walk_direction(direction)
		FLEEING:
			if player:
				if (player.global_position - global_position).length() < flee_distance:
					var direction = -(player.global_position - global_position)
					set_walk_direction(direction)
		RETURNING:
			if not home_area or home_area.overlaps_body(self):
				change_state(IDLE)

func _physics_process(delta):
	move_and_slide(velocity)

func check_to_flee():
	if not player:
		return
		
	if not state == FLEEING:
		var flee_chance = 1
		if awareness >= Constants.HIGH_AWARENESS_LEVEL:
			flee_chance = 101
		elif awareness >= Constants.MEDIUM_AWARENESS_LEVEL:
			flee_chance = 51
		
		var can_flee = randi()%flee_chance + 1
		if (player.global_position - global_position).length() < flee_distance and can_flee < flee_chance:
			print('fleeing with can_flee:', can_flee)
			change_state(FLEEING)

func change_state(new_state):
	if show_states:
		$Overhead/StateLabel.text = state_display_string(new_state)
	state = new_state
	var change_state_wait_time = randi()%5+1
	
	match new_state:
		WALKING:
			speed = walk_speed
			var direction = Vector2(randf()*2-1, randf()*2-1)
			set_walk_direction(direction)
		IDLE:
			velocity = Vector2()
		FLEEING:
			speed = run_speed
			change_state_wait_time = 1
			if player:
				var direction = -(player.global_position - global_position)
				set_walk_direction(direction)
		RETURNING:
			speed = walk_speed
			if not home_area:
				change_state(IDLE)
			elif not home_area.overlaps_body(self):
				var direction = home_area.global_position - global_position
				set_walk_direction(direction)
		
	$change_state_timer.wait_time = change_state_wait_time
	$change_state_timer.start()

func state_display_string(state):
	var response = "UNKNOWN"
	match state:
		IDLE:
			response = "IDLE"
		WALKING:
			response = "WALKING"
		FLEEING:
			response = "FLEEING"
		RETURNING:
			response = "RETURNING"
	return response

func set_walk_direction(direction):
	look_at(direction + global_position)
	velocity = direction.normalized() * speed
	$Overhead.set_rotation(-rotation)
	$Overhead.rect_global_position = Vector2(global_position.x - $Overhead/ProgressBar.rect_size.x/2, global_position.y - 50)

func _on_change_state_timer_timeout():
	if state == IDLE:
		change_state(WALKING)
	elif state == WALKING:
		change_state(IDLE)
	if state == FLEEING:
		if player:
			if (player.global_position - global_position).length() < flee_distance:
				var direction = -(player.global_position - global_position)
				set_walk_direction(direction)
				$change_state_timer.start()
			else:
				change_state(RETURNING)
		
func _on_Update_awareness(new_awareness):
	if new_awareness == 0:
		new_awareness = 1
	var percent = 1.0 if total_awareness == 0 else float(awareness) / total_awareness
	total_awareness = new_awareness
	awareness = percent * total_awareness
