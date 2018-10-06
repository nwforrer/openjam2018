extends Node

var envelope_scene
var money = 0

const money_label_format = "Money: %s"

func _ready():
	$Camera.target = $Player
	envelope_scene = preload("res://player/Envelope.tscn")
	update_money()
	
func update_money():
	$Camera/GUI/MoneyLabel.text = money_label_format % money

func _on_Player_spawn_envelope(pos, rot):
	var envelope = envelope_scene.instance()
	envelope.position = pos
	envelope.rotation = rot
	envelope.connect('envelope_collision', self, '_on_Envelope_collision')
	add_child(envelope)
	
func _on_Envelope_collision(env, collider):
	if collider.money_held:
		money += collider.money_held
		update_money()
	env.queue_free()
	collider.queue_free()
