extends Node

signal update_awareness

var envelope_scene
var laser_scene
var spam_filter_scene

var money = 0 setget set_money
var awareness = 0 setget set_awareness

var money_label
var awareness_label
var alert_label

var powerups = []

const money_label_format = "Money: %s"
const awareness_label_format = "Spam Awareness: %s"

func get_input():
	if Input.is_action_just_pressed('open_shop'):
		if $Camera/Shop.visible:
			close_shop()
		else:
			open_shop()

func spawn_spam_filters(count):
	# increased awareness tier, spawn spam filters
	var spawn_locations = $spam_filter_spawns.get_children()
	for loc in spawn_locations:
		var spam_filter = spam_filter_scene.instance()
		spam_filter.global_position = loc.global_position
		spam_filter.target = $Player
		spam_filter.connect('spawn_filter_shot', self, '_on_SpamFilter_shoot')
		add_child(spam_filter)

func set_money(new_money):
	money = new_money
	update_money()
	
func set_awareness(new_aware):
	var old_bucket = get_awareness_bucket(awareness)
	var new_bucket = get_awareness_bucket(new_aware)
	if new_aware > awareness and old_bucket != new_bucket:
		var count = 1
		if new_bucket == 'Medium':
			count = 2
		elif new_bucket == 'High':
			count = 3
		spawn_spam_filters(count)
			
	awareness = new_aware
	emit_signal('update_awareness', awareness)
	update_awareness()

func _ready():
	randomize()
	
	$Camera.target = $Player
	envelope_scene = preload("res://player/Envelope.tscn")
	spam_filter_scene = preload("res://spam_filter/SpamFilter.tscn")
	laser_scene = preload("res://spam_filter/Laser.tscn")
	
	$Camera/GUI/HealthBar.max_value = $Player.health
	$Camera/GUI/HealthBar.value = $Player.health
	
	money_label = find_node("MoneyLabel")
	awareness_label = find_node("AwarenessLabel")
	alert_label = find_node("AlertLabel")
	update_money()
	update_awareness()
	
func _process(delta):
	get_input()
	
func update_money():
	if money_label:
		money_label.text = money_label_format % money
	
func update_awareness():
	if awareness_label:
		var awareness_level = get_awareness_bucket(awareness)
		awareness_label.text = awareness_label_format % awareness_level

func get_awareness_bucket(aware):
	var awareness_level
	if aware == 0:
		awareness_level = 'None'
	elif aware > 0 and aware <= Constants.LOW_AWARENESS_LEVEL:
		awareness_level = 'Low'
	elif aware <= Constants.MEDIUM_AWARENESS_LEVEL:
		awareness_level = 'Medium'
	else:
		awareness_level = 'High'
	return awareness_level

func open_shop():
	$Camera/Shop.open(money)

func close_shop():
	$Camera/Shop.close()

func _on_Player_spawn_envelope(pos, rot):
	var envelope = envelope_scene.instance()
	envelope.position = pos
	envelope.rotation = rot
	envelope.connect('envelope_collision', self, '_on_Envelope_collision')
	add_child(envelope)

func _on_SpamFilter_shoot(pos, rot):
	var laser = laser_scene.instance()
	laser.position = pos
	laser.rotation = rot
	laser.connect('laser_collision', self, '_on_Laser_collision')
	add_child(laser)

func citizen_hit(collider):
	collider.awareness -= 1
	if collider.awareness <= 0:
		if collider.money_held:
			set_money(money + collider.money_held)
			
		if powerups.has(Constants.EXTEND_SCAM):
			collider.money_held /= 2
			collider.awareness = awareness
		else:
			collider.queue_free()

func spam_filter_hit(collider):
	collider.queue_free()

func _on_Envelope_collision(env, collider):
	if PhysicsLayerUtils.obj_on_layer(collider, 'citizen'):
		if get_tree().get_nodes_in_group('spam_filters').size() > 0:
			print('still have spam filters')
		else:
			citizen_hit(collider)
	elif PhysicsLayerUtils.obj_on_layer(collider, 'spam_filter'):
		spam_filter_hit(collider)
		
	env.queue_free()
	
func _on_Laser_collision(laser, collider):
	if PhysicsLayerUtils.obj_on_layer(collider, 'player'):
		collider.set_health(collider.health - 1)
		$Camera/GUI/HealthBar.value = collider.health
		if collider.health <= 0:
			print('game over')
	laser.queue_free()

func _on_awareness_timer_timeout():
	alert_label.text = "Citizens, be aware of spam!"
	alert_label.show()
	$alert_timer.start()
	
	set_awareness(awareness + 10)
	
	$awareness_timer.wait_time *= 2
	$awareness_timer.start()

func _on_alert_timer_timeout():
	alert_label.hide()

func _on_Shop_bought_powerup(powerup, cost):
	if cost > money:
		print('too expensive')
		return
		
	set_money(money - cost)
	
	close_shop()
	
	match powerup:
		Constants.CHANGE_STRAT:
			set_awareness(awareness / 2)
		Constants.EXTEND_SCAM:
			powerups.push_back(Constants.EXTEND_SCAM)

func _on_Shop_close_shop():
	close_shop()
