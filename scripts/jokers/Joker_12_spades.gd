class_name Joker_12_spades extends Node

var joker_effect = "When you play a spade, x2 the score"
var joker_price: int = 6

var activation_window: String = 'on_card_played'

func activate(_activation_window: String, deck: Deck, ui: Ui, _card: Card):
	if activation_window == _activation_window:
		if _card.card_suit == 'spades':
			highlight()
			ui.get_parent().enemy.set_visual_aid_label('x2')
			await wait(0.3)
			ui.get_parent().enemy.set_visual_aid_label('')
			ui.get_parent().enemy.set_score_value(ui.get_parent().enemy.score * 2)
			await wait(1)
			
func wait(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	while timer.time_left > 0:
		await get_tree().process_frame
	
	timer.queue_free()
	
	
func highlight():
	$"../Sprite2D".set_modulate(Color(1,0.1,0.2,1))
	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()	
	$"../Sprite2D".set_modulate(Color(1,1,1,1))
