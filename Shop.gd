extends Control

signal close_shop
signal bought_powerup

var is_open = false

export (int) var change_strat_cost = 10
export (int) var extend_scam_cost = 20

func get_input():
	if Input.is_action_just_pressed('open_shop'):
		close()

func _process(delta):
	if not is_open:
		return
		
	get_input()

func open(money):
	$open_timer.start()
	
	get_tree().paused = true
	show()
	
	$ChangeStratButton.text = 'Change Strategy: %s' % change_strat_cost
	$ChangeStratButton.disabled = true if money < change_strat_cost else false
	
	$ExtendScamButton.text = 'Extend Scam: %s' % extend_scam_cost
	$ExtendScamButton.disabled = true if money < extend_scam_cost else false

func close():
	is_open = false
	get_tree().paused = false
	hide()
	
func _on_ChangeStratButton_pressed():
	emit_signal('bought_powerup', Constants.CHANGE_STRAT, change_strat_cost)

func _on_ExtendScamButton_pressed():
	emit_signal('bought_powerup', Constants.EXTEND_SCAM, extend_scam_cost)
	
func _on_open_timer_timeout():
	is_open = true
