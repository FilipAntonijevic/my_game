class_name Joker_13_hearts extends Node

var joker_effect = "When you play 3 hearts deal 20 dmg"
var joker_price: int = 5

var activation_window: String = 'on_card_played'
var suit_counter: int = 3

func activate(_activation_window: String, deck: Deck, ui: Ui, card: Card):
	
	if activation_window == _activation_window:
		if card.card_suit == 'hearts':
			suit_counter -= 1
			if suit_counter == 0:
				suit_counter = 3
				ui.add_to_score(10)
				highlight()

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
