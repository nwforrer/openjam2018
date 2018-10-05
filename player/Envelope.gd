extends KinematicBody2D

var speed = 500

func _ready():
	pass
	
func _physics_process(delta):
	var velocity = Vector2(speed, 0).rotated(rotation)
	move_and_collide(velocity * delta)


func _on_LifeTimer_timeout():
	queue_free()
