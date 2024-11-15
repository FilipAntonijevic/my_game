class_name Aces_joker extends Node

var activation_window = 'on_cards_dealt'
func activate(_activation_window: String, deck: Deck, ui: Ui, _card: Card):
	if activation_window == _activation_window:
		var array_of_stacks = ui.stacks.get_children()
		for stack in array_of_stacks:
			for i in range(stack.cards_in_stack.size() - 1, -1, -1): #ovako iterira niz otpozadi, sto mora, jer ako izbaci nekog keca iz steka, ostalim kartama u steku se promene indeksi
				var card = stack.cards_in_stack[i]
				if card.card_value == 1:
					stack.move_card_from_stack_to_a_pile(deck, card)
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
