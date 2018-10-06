extends Camera2D

var target
var target_offset = Vector2()

func _ready():
	target_offset = OS.window_size / 2
	
func _physics_process(delta):
	if target:
		position = target.position - target_offset
