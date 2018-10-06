extends Control

signal close_shop
signal bought_powerup

export (int) var change_strat_cost = 10

func open(money):
	$ChangeStratButton.text = 'Change Strategy: %s' % change_strat_cost
	
	$ChangeStratButton.disabled = true if money < change_strat_cost else false

func _on_ChangeStratButton_pressed():
	emit_signal('bought_powerup', Constants.CHANGE_STRAT, change_strat_cost)