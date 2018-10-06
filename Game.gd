extends Node

signal update_awareness

var envelope_scene
var money = 0
var awareness = 0

var money_label
var awareness_label
var alert_label

const money_label_format = "Money: %s"
const awareness_label_format = "Citizen Awareness: %s"

func _ready():
	$Camera.target = $Player
	envelope_scene = preload("res://player/Envelope.tscn")
	
	money_label = find_node("MoneyLabel")
	awareness_label = find_node("AwarenessLabel")
	alert_label = find_node("AlertLabel")
	update_money()
	update_awareness()
	
func update_money():
	if money_label:
		money_label.text = money_label_format % money
	
func update_awareness():
	if awareness_label:
		awareness_label.text = awareness_label_format % awareness

func _on_Player_spawn_envelope(pos, rot):
	var envelope = envelope_scene.instance()
	envelope.position = pos
	envelope.rotation = rot
	envelope.connect('envelope_collision', self, '_on_Envelope_collision')
	add_child(envelope)
	
func _on_Envelope_collision(env, collider):
	collider.awareness -= 1
	if collider.awareness <= 0:
		if collider.money_held:
			money += collider.money_held
			update_money()
		collider.queue_free()
		
	env.queue_free()

func _on_awareness_timer_timeout():
	alert_label.text = "Citizens, be aware of spam!"
	$alert_timer.start()
	
	awareness += 10
	emit_signal('update_awareness', awareness)
	update_awareness()
	$awareness_timer.wait_time *= 2
	$awareness_timer.start()

func _on_alert_timer_timeout():
	alert_label.text = ""
