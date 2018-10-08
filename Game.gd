extends Node

signal update_money
signal update_awareness
signal update_effectiveness
signal send_alert

signal start_defend
signal end_defend

export (int) var max_strength = 35
export (int) var awareness_inc_step = 10

var envelope_scene
var laser_scene
var spam_filter_scene
var citizen_scene

var spam_filter_count = 0
var citizen_spawn_count = 1

var money = 0 setget set_money
var awareness = 0 setget set_awareness

var powerups = []

func get_input():
	if Input.is_action_just_pressed('pause'):
		pause()

func spawn_spam_filters(count):
	emit_signal('start_defend')
	# increased awareness tier, spawn spam filters
	var spawn_locations = $spam_filter_spawns.get_children()
	for loc in spawn_locations:
		var spam_filter = spam_filter_scene.instance()
		spam_filter.global_position = loc.global_position
		spam_filter.target = $Player
		spam_filter.connect('spawn_filter_shot', self, '_on_SpamFilter_shoot')
		add_child(spam_filter)
		
		spam_filter_count += 1

func set_money(new_money):
	money = new_money
	update_money()
	
func set_awareness(new_aware):
	awareness = new_aware
	update_awareness()
	
	if awareness >= 100:
		game_over()
	
func start():
	$CanvasLayer/GameOver.hide()
	$CanvasLayer/PauseMenu.hide()
	
	$spam_filter_timer.stop()
	$spam_filter_timer.wait_time = 10
	$spam_filter_timer.start()
	
	get_tree().call_group('spam_filters', 'queue_free')
	get_tree().call_group('projectiles', 'queue_free')
	get_tree().call_group('citizens', 'queue_free')
	
	$Player.reset()
	$Player.position = $PlayerStart.position
	
	money = 0
	awareness = 0
	spam_filter_count = 0
	
	$CanvasLayer/Messaging.reset()
	
	$awareness_timer.start()
	
	update_money()
	update_awareness()
	update_effectiveness(0)
	
	spawn_citizens()

func pause():
	get_tree().paused = true
	$CanvasLayer/PauseMenu.show()

func game_over():
	get_tree().paused = true
	var high_score
	var high_score_money
	var high_score_file = File.new()
	if not high_score_file.file_exists("user://high_score.save"):
		print('creating high score file')
		high_score = true
		high_score_money = money
		high_score_file.open("user://high_score.save", File.WRITE)
		high_score_file.store_string(str(money))
		high_score_file.close()
	else:
		print('high score file exists')
		high_score_file.open("user://high_score.save", File.READ_WRITE)
		var line = high_score_file.get_as_text()
		if money > int(line):
			print('new high score!')
			high_score = true
			high_score_money = money
			high_score_file.store_string(str(money))
		else:
			print('did not pass high score')
			high_score = false
			high_score_money = int(line)
		high_score_file.close()
	$CanvasLayer/GameOver.win(money, high_score, high_score_money)
	$CanvasLayer/GameOver.show()
	
func spawn_citizens():
	var areas = $CitizenAreaContainer.get_children()
	for area in areas:
		spawn_citizen(area)

func spawn_citizen(area):
	var citizen = citizen_scene.instance()
	citizen.player_path = $Player.get_path()
	citizen.update_awareness(awareness)
	connect('start_defend', citizen, '_on_Game_start_defend')
	connect('end_defend', citizen, '_on_Game_end_defend')
	
	if get_tree().get_nodes_in_group('spam_filters').size() > 0:
		citizen._on_Game_start_defend()
	area.add_child(citizen)

func _ready():
	randomize()
	
	envelope_scene = preload("res://player/Envelope.tscn")
	spam_filter_scene = preload("res://spam_filter/SpamFilter.tscn")
	laser_scene = preload("res://spam_filter/Laser.tscn")
	citizen_scene = preload("res://citizen/Citizen.tscn")
	
	start()
	
func _process(delta):
	get_input()
	
func update_money():
	emit_signal('update_money', money)
	
func update_awareness():
	emit_signal('update_awareness', awareness)
	
func update_effectiveness(delta):
	$Player.effectiveness += delta
	if $Player.effectiveness < 5:
		$Player.effectiveness = 5
	emit_signal('update_effectiveness', $Player.effectiveness)

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
	update_effectiveness(1)
	var hit_strength = max_strength*$Player.effectiveness/$Player.max_effectiveness
	collider.awareness -= hit_strength
	if collider.awareness <= 0:
		if collider.money_held:
			$Coin.play()
			set_money(money + collider.money_held)
			
		if powerups.has(Constants.EXTEND_SCAM):
			collider.money_held /= 2
			collider.awareness = awareness
		else:
			collider.queue_free()

func start_spam_filter_timer():
	if $spam_filter_timer.wait_time > 5:
		$spam_filter_timer.wait_time -= 1
	$spam_filter_timer.start()

func spam_filter_hit(collider):
	collider.queue_free()
	$Explosion.play()
	spam_filter_count -= 1
	if spam_filter_count <= 0:
		emit_signal('end_defend')
		
		if $spam_filter_timer.is_stopped():
			start_spam_filter_timer()

func _on_Envelope_collision(env, collider):
	if PhysicsLayerUtils.obj_on_layer(collider, 'citizen'):
		if get_tree().get_nodes_in_group('spam_filters').size() > 0:
			$Block.play()
		else:
			citizen_hit(collider)
	elif PhysicsLayerUtils.obj_on_layer(collider, 'spam_filter'):
		spam_filter_hit(collider)
		
	env.queue_free()
	
func _on_Laser_collision(laser, collider):
	if PhysicsLayerUtils.obj_on_layer(collider, 'player'):
		update_effectiveness(-3 - awareness / awareness_inc_step)
	laser.queue_free()

func _on_awareness_timer_timeout():
	set_awareness(awareness + awareness_inc_step)
	$awareness_timer.start()

func _on_Music_finished():
	$Music.play()

func _on_citizen_spawn_timer_timeout():
	spawn_citizens()

func _on_spam_filter_timer_timeout():
	emit_signal('send_alert')
	spawn_spam_filters(1)
