extends VBoxContainer

var is_alerting = false
var scroll_speed = 200

var alert_text_choices = ["Citizens, be aware of increased spam!", 
						  "Email providers implementing smarter spam detection!"]

func _ready():
	reset()
	
func reset():
	hide()
	$Timer.stop()

func _on_Game_send_alert():
	is_alerting = true
	
	rect_global_position.x = 0
	$NinePatchRect/Label.text = alert_text_choices[randi()%alert_text_choices.size()]
	show()
	$Timer.start()

func _process(delta):
	if not is_alerting:
		return
	
	rect_global_position.x += scroll_speed * delta

func _on_Timer_timeout():
	is_alerting = false
	
	hide()
