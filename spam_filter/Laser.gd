extends KinematicBody2D

signal laser_collision

var speed = 500

func _ready():
	pass
	
func _physics_process(delta):
	var velocity = Vector2(speed, 0).rotated(rotation)
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		emit_signal('laser_collision', self, collision_info.collider)

func _on_LifeTimer_timeout():
	queue_free()
