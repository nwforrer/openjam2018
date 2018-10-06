extends KinematicBody2D

signal spawn_filter_shot

export (NodePath) var target_node_path
export (int) var target_distance = 200 # will be the orbiting radius once reached
export (float) var orbit_speed = PI/2 # 2*PI = 1 rotation per second
export (float) var speed = 300 # pixels/second

enum STATES {TRACKING, ORBITING}

var target
var velocity = Vector2()

var orbit_angle = 0
var state

func _ready():
	if target_node_path:
		target = get_node(target_node_path)
		
	change_state(TRACKING)
	
func _physics_process(delta):
	match state:
		TRACKING:
			if target:
				var direction = (target.global_position - global_position)
				velocity = direction.normalized() * speed
				look_at(target.global_position)
				
				if direction.length() < target_distance:
					change_state(ORBITING)
			
			move_and_slide(velocity)
			
		ORBITING:
			if target:
				var tx = target.global_position.x + target_distance*cos(orbit_angle)
				var ty = target.global_position.y + target_distance*sin(orbit_angle)
				
				global_position = Vector2(tx, ty)
				look_at(target.global_position)
				
				orbit_angle += orbit_speed*delta
	
func change_state(new_state):
	state = new_state
	
	match new_state:
		ORBITING:
			$shoot_timer.start()
			if target:
				orbit_angle = atan2(global_position.y - target.global_position.y, global_position.x - target.global_position.x)


func _on_shoot_timer_timeout():
	emit_signal('spawn_filter_shot', $muzzle_location.global_position, rotation)
