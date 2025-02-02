class_name Joker_12_hearts extends Node

var joker_effect = "When you play a heart, x2 the score"

var activation_window: String = 'on_card_played'
var highest_replayed_card_value: int = 0

func activate(_activation_window: String, deck: Deck, ui: Ui, _card: Card):
	if activation_window == _activation_window:
		if _card.card_suit == 'hearts':
			ui.get_parent().enemy.set_visual_aid_label('x2')
			await get_tree().create_timer(0.3).timeout
			ui.get_parent().enemy.set_visual_aid_label('')
			ui.get_parent().enemy.set_score_value(ui.get_parent().enemy.score * 2)
			await get_tree().create_timer(0.7).timeout
			highlight()
			
	#if activation_window == _activation_window:
	#	if _card.card_suit == 'spades' and _card.card_value > highest_replayed_card_value:
	#		highest_replayed_card_value += 1 
	#		ui.add_to_score(_card.card_value)
	#		ui.card_piles.current_card_value_on_spades_pile -= 1
	#		ui.place_card_on_according_pile(_card)
	#		highlight()

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
