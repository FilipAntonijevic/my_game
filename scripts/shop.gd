class_name Shop extends Node2D

@onready var card_scene: PackedScene = preload("res://scenes/card.tscn")
@onready var spawnpoints = $spawnpoints.get_children() 
var drawn_cards = []
var original_deck: Deck = null
@onready var desk: Sprite2D = $desk
@onready var jokers = $Jokers
@onready var joker_effect_label = $joker_effect_label
@onready var sell_joker_label = $sell_joker_label
@onready var gold_ammount_label = $gold_ammount_label
@onready var excavate_cards_button = $desk/exacuviate
@onready var excavation_cost_label = $desk/exacuviate/excavation_cost_label
@onready var next_button = $next_button

@onready var gem_1_position = $desk/gems_positions/gem_1_position
@onready var gem_2_position = $desk/gems_positions/gem_2_position
@onready var gem_3_position = $desk/gems_positions/gem_3_position

@onready var small_topaz = $small_topaz
@onready var small_sapphire = $small_sapphire
@onready var small_emerald = $small_emerald
@onready var small_ruby = $small_ruby

@onready var medium_topaz = $medium_topaz
@onready var medium_sapphire = $medium_sapphire
@onready var medium_emerald = $medium_emerald
@onready var medium_ruby = $medium_ruby

@onready var big_topaz = $big_topaz
@onready var big_sapphire = $big_sapphire
@onready var big_emerald = $big_emerald
@onready var big_ruby = $big_ruby

var all_gems_list: Array 
var chosen_gems: Array

var topaz_touch: bool = false
var emerald_touch: bool = false
var ruby_touch: bool = false
var sapphire_touch: bool = false

var current_selected_joker_for_movement = null
var is_dragging_a_joker: bool = false

var excavation_cost: int = 1
signal show_board

var main: Main 
	
func set_deck(deck: Deck) -> void:
	original_deck = deck
	
func get_random_card_from_deck() -> Card:
	if get_parent() and original_deck and original_deck.card_collection.size() > 0:
		var random_index = randi() % get_parent().original_deck.card_collection.size()
		if original_deck.card_collection.has(random_index):
			return original_deck.card_collection[random_index]
		else:
			return get_random_card_from_deck()
	else:
		return null

		
func excavate_card() -> void:
	
	var card = get_random_card_from_deck()
	if check_if_card_can_be_excavated(card): 
		drawn_cards.append(card)  
		
		for card_place in spawnpoints:
			if !card_place.has_node("Card"):
				card_place.set_card(card)
				card.set_card_sprite(card.card_path)
				return
	else:
		excavate_card()


func check_if_card_can_be_excavated(new_card: Card) -> bool:
	if !new_card:
		return false
		
	for card in drawn_cards:
		if card.card_suit == new_card.card_suit && card.card_value == new_card.card_value:
			return false
	return true

func load_jokers() -> void:
	var main_jokers = get_parent().jokers
	if main_jokers:
		for i in range(0,5):
			if main_jokers.get_child(i).joker != null:
				var joker = main_jokers.get_child(i).joker.duplicate(DUPLICATE_SCRIPTS | DUPLICATE_GROUPS | DUPLICATE_SIGNALS)
				joker.connect("mouse_entered_joker", Callable(self, "_on_mouse_entered_joker"))
				joker.connect("mouse_exited_joker", Callable(self, "_on_mouse_exited_joker"))
				joker.connect("joker_sold", Callable(self, "_on_joker_sold"))
				jokers.get_child(i).set_joker(joker)
	
	if false:
		for joker_place in main_jokers.get_children():
			if joker_place.joker != null: 
				var new_joker = joker_place.joker.duplicate()
				for new_joker_place in jokers.get_children():
					if new_joker_place.joker == null:
						new_joker_place.remove_child(new_joker)
						new_joker_place.set_joker(new_joker)
						#new_joker.position = jokers.jokers_positions[jokers.get_child_count() - 2]
						new_joker.this_jokers_position = new_joker.position
						new_joker.connect("mouse_entered_joker", Callable(self, "_on_mouse_entered_joker"))
						new_joker.connect("mouse_exited_joker", Callable(self, "_on_mouse_exited_joker"))
						new_joker.connect("joker_sold", Callable(self, "_on_joker_sold"))
						break
						
func _on_mouse_entered_joker(joker: Joker) -> void:
	if joker.has_node("effect"):
		var child = joker.get_node("effect")
		joker_effect_label.text = str(child.joker_effect)
		var sell_value: int = int(joker.effect.joker_price / 2)
		if sell_value == 1:
			sell_joker_label.set_text("Right click to sell for: " + str(sell_value) + " coin")
		else:
			sell_joker_label.set_text("Right click to sell for: " + str(sell_value) + " coins")

	
func _on_mouse_exited_joker() -> void:
	joker_effect_label.text = ""
	sell_joker_label.set_text('')

func _on_joker_sold(joker: Joker) -> void:
	for joker_place in jokers.get_children():
		if joker_place.joker == joker:
			joker_place.remove_child(joker)
			joker_place.joker = null
			var card = turn_joker_into_a_card(joker)
			original_deck.add_card(card)
			get_parent().total_gold += int(joker.effect.joker_price / 2)
			gold_ammount_label.set_text(str(get_parent().total_gold))
			joker_effect_label.set_text("Hover a card to see its joker effect")
			sell_joker_label.set_text("")
	

func turn_joker_into_a_card(joker: Joker) -> Card:
	var card: Card = card_scene.instantiate()
	card.set_card_value(joker.card_value)
	card.set_card_suit(joker.card_suit)
	card.set_card_path(joker.card_path)
	return card

func get_three_unique_gems():
	var shuffled_gems = all_gems_list.duplicate()
	shuffled_gems.shuffle() 
	return shuffled_gems.slice(0, 3)
	
	
func _ready() -> void:
	
	all_gems_list = [small_emerald, small_ruby, small_sapphire, small_topaz, medium_emerald, medium_ruby, medium_sapphire, medium_topaz, big_topaz, big_emerald, big_ruby, big_sapphire]
	chosen_gems = get_three_unique_gems()
	chosen_gems[0].global_position = gem_1_position.global_position
	chosen_gems[1].global_position = gem_2_position.global_position
	chosen_gems[2].global_position = gem_3_position.global_position
	
	excavation_cost = 1
	excavation_cost_label.set_text(str(excavation_cost) + "g")
		
	joker_effect_label.z_index = 100
	load_jokers()
	
	gold_ammount_label.set_text(str(get_parent().total_gold))
	for card_place in spawnpoints:
		card_place.connect("joker_bought", Callable(self, "_on_joker_bought"))
	
	var timer1 = Timer.new()
	timer1.wait_time = 0.1
	add_child(timer1)
	timer1.start()
	await timer1.timeout
	excavate_card()
	timer1.start()
	await timer1.timeout
	excavate_card()
	timer1.start()
	await timer1.timeout
	excavate_card()
	timer1.queue_free()	
	#excavate_cards(5)


func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_parent().set_jokers(jokers)
	for joker_place in jokers.get_children():
		if joker_place.joker != null:
			#joker_place.remove_child(joker_place.joker)
			joker_place.joker.free()
		joker_place.free()
	get_parent().original_deck = copy_deck()
	emit_signal("show_board") 
	hide()  

func copy_deck() -> Deck:
	var deck_copy = Deck.new()

	for card_id in original_deck.card_collection.keys():
		var card = original_deck.card_collection[card_id]
		if is_instance_valid(card):
			var new_card = card.duplicate() 
			if card.topaz:
				new_card.topaz = true
			if card.emerald:
				new_card.emerald = true
			if card.ruby:
				new_card.ruby = true
			if card.sapphire:
				new_card.sapphire = true
			deck_copy.add_card(new_card)
	
	return deck_copy
	
func _on_exacuviate_pressed() -> void:
	if excavation_cost <= get_parent().total_gold and drawn_cards.size() < 8:
		get_parent().total_gold -= excavation_cost
		excavation_cost *= 2
		excavation_cost_label.set_text(str(excavation_cost))
		gold_ammount_label.set_text(str(get_parent().total_gold))
		excavate_card()


func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		pass


func _on_joker_bought(card: Card) -> void:
	#get_parent().add_joker(card)
	add_joker(card)
	original_deck.remove_card_by_value_and_suit(card)
	drawn_cards.erase(card)


func add_joker(card: Card) -> void:
	var path: String = "res://scenes/jokers/Joker_" + str(card.card_value) + "_" + str(card.card_suit) + ".tscn"
	var joker_scene = load(path)
	if joker_scene:
		var joker = joker_scene.instantiate()
		if joker:
			for joker_place in jokers.get_children():
				if joker_place.joker == null:
					joker_place.set_joker(joker)
					joker.this_jokers_position = joker.position
					joker.card_value = card.card_value
					joker.card_suit = card.card_suit
					joker.card_path = card.card_path
					joker.connect("mouse_entered_joker", Callable(self, "_on_mouse_entered_joker"))
					joker.connect("mouse_exited_joker", Callable(self, "_on_mouse_exited_joker"))
					joker.connect("joker_sold", Callable(self, "_on_joker_sold"))
					return 
	
func drag_selected_joker(joker: Joker) -> void:
	
	joker.get_parent().joker = null
#	joker.get_parent().remove_child(joker)
	current_selected_joker_for_movement = joker
	#current_selected_joker_for_movement_position = current_selected_joker_for_movement.global_position
	is_dragging_a_joker = true
	joker.is_dragging = true
	current_selected_joker_for_movement.z_index = 101  

func assign_new_position_to_previously_dragged_joker(joker: Joker) -> void:
	
	if current_selected_joker_for_movement == null:
			return
			
	if check_if_joker_can_be_placed_on_a_joker_palce():
		pass
	
	for joker_place in jokers.get_children():
		if joker_place.mouse_is_inside_the_joker_place and joker_place.joker == null:
			joker.get_parent().remove_child(joker)
			joker_place.remove_child(joker)
			joker_place.set_joker(joker)
			joker.global_position = joker_place.global_position
			joker.z_index = 1
			return
	
	for joker_place in jokers.get_children():
		if joker_place.joker == null:
			for child in joker_place.get_children():
				if child == joker:
					joker.get_parent().remove_child(joker)
					joker_place.remove_child(joker)
					joker_place.set_joker(joker)
					joker.global_position = joker_place.global_position
					joker.z_index = 1
					return
					
	for joker_place in jokers.get_children():
		if joker_place.joker == null:
			joker.get_parent().remove_child(joker)
			joker_place.remove_child(joker)
			joker_place.set_joker(joker)
			joker.global_position = joker_place.global_position
			joker.z_index = 1
			return
		#current_selected_joker_for_movement.global_position = joker.last_joker_position

func update_jokers_positions():
	if is_dragging_a_joker:
		var position_1: int = jokers.joker_place_1.global_position.x
		var position_2: int = jokers.joker_place_2.global_position.x
		var position_3: int = jokers.joker_place_3.global_position.x
		var position_4: int = jokers.joker_place_4.global_position.x
		var position_5: int = jokers.joker_place_5.global_position.x
		var top_position = jokers.joker_place_1.global_position.y + 50
		var bottom_position = jokers.joker_place_1.global_position.y - 50
		var x = get_global_mouse_position().x
		if get_global_mouse_position().y < top_position and get_global_mouse_position().y > bottom_position:
			if x <= position_1: #less then 1
				move_jokers_to_left_or_right(1, "right")
			if x >= position_1 and x <= (position_1 + position_2)/2 : #more_then 1, less then half
				pass
			if x >= (position_1 + position_2)/2 and x <= position_2: #more then half, less then 2
				move_jokers_to_left_or_right(2, "right")
			if x >= position_2 and x <= (position_2 + position_3)/2 : #more then 2 less then half
				move_jokers_to_left_or_right(2, "left")
			if x >= (position_2 + position_3)/2 and x <= position_3:
				move_jokers_to_left_or_right(3, "right")
			if x >= position_3 and x <= (position_3 + position_4)/2 :
				move_jokers_to_left_or_right(3, "left")
			if x >= (position_3 + position_4)/2 and x <= position_4:
				move_jokers_to_left_or_right(4, "right")
			if x > position_4 and x < (position_4 + position_5)/2 :
				move_jokers_to_left_or_right(4, "left")
			if x >= (position_4 + position_5)/2 and x <= position_5:
				pass
			if x > position_5:
				move_jokers_to_left_or_right(5, "left")
				
func move_jokers_to_left_or_right(starting_joker: int, side: String) -> void:
	if side == "left":
		move_jokers_to_the_left(starting_joker - 1)
	if side == "right":
		move_jokers_to_the_right(starting_joker - 1)

func move_jokers_to_the_left(starting_joker_int):
	var empty_joker_place = null
	var empty_joker_place_int = -1
	
	for j in range(0, jokers.get_child_count()):
		var joker_place = jokers.get_child(j)
		if joker_place.joker == null:
			empty_joker_place = joker_place
			empty_joker_place_int = j
		if j == starting_joker_int:
			if empty_joker_place == null:
				return false
			else:
				for i in range(empty_joker_place_int, starting_joker_int):
					if i + 1 <= starting_joker_int:
						var moving_joker_place = jokers.get_child(i + 1)
						var joker = moving_joker_place.joker
						var new_joker_place = jokers.get_child(i) 
						
						#aniamtion
						#var tween = get_tree().create_tween()
						#tween.tween_property(joker, "global_position:x", new_joker_place.global_position.x, 0.5) \
						#	.set_trans(Tween.TRANS_QUAD) \
						#	.set_ease(Tween.EASE_OUT)
						#await tween.finished
						
						moving_joker_place.remove_child(joker)
						moving_joker_place.joker = null
						new_joker_place.set_joker(joker)
						
	return true


func move_jokers_to_the_right(starting_joker_int: int) -> bool:
	var empty_joker_place = null
	var empty_joker_place_int = -1
	
	for j in range(jokers.get_child_count() - 1, -1, -1):
		var joker_place = jokers.get_child(j)
		if joker_place.joker == null:
			empty_joker_place = joker_place
			empty_joker_place_int = j
		if j == starting_joker_int:
			if empty_joker_place == null:
				return false
			else:
				for i in range(empty_joker_place_int, starting_joker_int - 1, -1):
					if i - 1 >= starting_joker_int:
						var moving_joker_place = jokers.get_child(i - 1)
						var joker = moving_joker_place.joker
						var new_joker_place = jokers.get_child(i) 
						
						#aniamtion
						#var tween = get_tree().create_tween()
						#tween.tween_property(joker, "global_position:x", new_joker_place.global_position.x, 0.5) \
						#	.set_trans(Tween.TRANS_QUAD) \
						#	.set_ease(Tween.EASE_OUT)
						#await tween.finished
						
						moving_joker_place.remove_child(joker)
						moving_joker_place.joker = null
						new_joker_place.set_joker(joker)
						
	return true

	
func check_if_joker_can_be_placed_on_a_joker_palce() -> bool:
	return false



func _on_medium_emerald_mouse_entered() -> void:
	medium_emerald.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Choose a card to make it emerald\n-when played, this card plays again with 0 base value.")
	sell_joker_label.set_text("Click to buy for 2$")
func _on_medium_emerald_mouse_exited() -> void:
	medium_emerald.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_medium_sapphire_mouse_entered() -> void:
	medium_sapphire.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Choose a card to make it sapphire\n-this card can be placed on any card with same suit.")
	sell_joker_label.set_text("Click to buy for 2$")
func _on_medium_sapphire_mouse_exited() -> void:
	medium_sapphire.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_medium_ruby_mouse_entered() -> void:
	medium_ruby.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Choose a card to make it ruby\n-this cards base value +10.")
	sell_joker_label.set_text("Click to buy for 2$")
func _on_medium_ruby_mouse_exited() -> void:
	medium_ruby.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_medium_topaz_mouse_entered() -> void:
	medium_topaz.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Choose a card to make it topaz\n-this card can't be locked, when played stun opponent.")
	sell_joker_label.set_text("Click to buy for 2$")
func _on_medium_topaz_mouse_exited() -> void:
	medium_topaz.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_small_emerald_mouse_entered() -> void:
	small_emerald.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make a random card emerald\n-when played, this card plays again with 0 base value.")
	sell_joker_label.set_text("Click to buy for 1$")
func _on_small_emerald_mouse_exited() -> void:
	small_emerald.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_small_topaz_mouse_entered() -> void:
	small_topaz.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make a random card topaz\n-this card can't be locked, when played stun opponent.")
	sell_joker_label.set_text("Click to buy for 1$")
func _on_small_topaz_mouse_exited() -> void:
	small_topaz.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_small_sapphire_mouse_entered() -> void:
	small_sapphire.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make a random card sapphire\n-this card can be placed on any card with same suit.")
	sell_joker_label.set_text("Click to buy for 1$")
func _on_small_sapphire_mouse_exited() -> void:
	small_sapphire.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_small_ruby_mouse_entered() -> void:
	small_ruby.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make a random card ruby\n-this cards base value +10.")
	sell_joker_label.set_text("Click to buy for 1$")
func _on_small_ruby_mouse_exited() -> void:
	small_ruby.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_big_emerald_mouse_entered() -> void:
	big_emerald.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make all cards in shop emerald\n-when played, this card plays again with 0 base value.")
	sell_joker_label.set_text("Click to buy for 5$")
func _on_big_emerald_mouse_exited() -> void:
	big_emerald.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_big_topaz_mouse_entered() -> void:
	big_topaz.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make all cards in shop topaz\n-this card can't be locked, when played stun opponent.")
	sell_joker_label.set_text("Click to buy for 5$")
func _on_big_topaz_mouse_exited() -> void:
	big_topaz.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_big_sapphire_mouse_entered() -> void:
	big_sapphire.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make all cards in shop sapphire\n-this card can be placed on any card with same suit.")
	sell_joker_label.set_text("Click to buy for 5$")
func _on_big_sapphire_mouse_exited() -> void:
	big_sapphire.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")
func _on_big_ruby_mouse_entered() -> void:
	big_ruby.set_modulate(Color(1.3, 1.3, 1.3, 1))
	joker_effect_label.set_text("Make all cards in shop ruby\n-this cards base value +10.")
	sell_joker_label.set_text("Click to buy for 5$")
func _on_big_ruby_mouse_exited() -> void:
	big_ruby.set_modulate(Color(1, 1, 1, 1))
	joker_effect_label.set_text("")
	sell_joker_label.set_text("")



func _on_medium_topaz_pressed() -> void:
	topaz_touch = true
	medium_topaz.global_position = Vector2(-100,-100)
	_on_medium_topaz_mouse_exited()
func _on_medium_ruby_pressed() -> void:
	ruby_touch = true
	medium_ruby.global_position = Vector2(-100,-100)
	_on_medium_ruby_mouse_exited()
func _on_medium_sapphire_pressed() -> void:
	sapphire_touch = true
	medium_sapphire.global_position = Vector2(-100,-100)
	_on_medium_sapphire_mouse_exited()
func _on_medium_emerald_pressed() -> void:
	emerald_touch = true
	medium_emerald.global_position = Vector2(-100,-100)
	_on_medium_emerald_mouse_exited()
func _on_small_emerald_pressed() -> void:
	var random_card = drawn_cards.pick_random()
	random_card.highlight_emerald_card()
	random_card.topaz = false
	random_card.emerald = true
	random_card.ruby = false
	random_card.sapphire = false
	small_emerald.global_position = Vector2(-100,-100)
	_on_small_emerald_mouse_exited()
func _on_small_topaz_pressed() -> void:
	var random_card = drawn_cards.pick_random()
	random_card.highlight_topaz_card()
	random_card.topaz = true
	random_card.emerald = false
	random_card.ruby = false
	random_card.sapphire = false
	small_topaz.global_position = Vector2(-100,-100)
	_on_small_topaz_mouse_exited()
func _on_small_sapphire_pressed() -> void:
	var random_card = drawn_cards.pick_random()
	random_card.highlight_sapphire_card()
	random_card.topaz = false
	random_card.emerald = false
	random_card.ruby = false
	random_card.sapphire = true
	small_sapphire.global_position = Vector2(-100,-100)
	_on_small_sapphire_mouse_exited()
func _on_small_ruby_pressed() -> void:
	var random_card = drawn_cards.pick_random()
	random_card.highlight_ruby_card()
	random_card.topaz = false
	random_card.emerald = false
	random_card.ruby = true
	random_card.sapphire = false
	small_ruby.global_position = Vector2(-100,-100)
	_on_small_ruby_mouse_exited()
func _on_big_emerald_pressed() -> void:
	for card in drawn_cards:
		card.highlight_emerald_card()
		card.topaz = false
		card.emerald = true
		card.ruby = false
		card.sapphire = false
	big_emerald.global_position = Vector2(-100,-100)
	_on_big_emerald_mouse_exited()
func _on_big_topaz_pressed() -> void:
	for card in drawn_cards:
		card.highlight_topaz_card()
		card.topaz = true
		card.emerald = false
		card.ruby = false
		card.sapphire = false
	big_topaz.global_position = Vector2(-100,-100)
	_on_big_topaz_mouse_exited()
func _on_big_sapphire_pressed() -> void:
	for card in drawn_cards:
		card.highlight_sapphire_card()
		card.topaz = false
		card.emerald = false
		card.ruby = false
		card.sapphire = true
	big_sapphire.global_position = Vector2(-100,-100)
	_on_big_sapphire_mouse_exited()
func _on_big_ruby_pressed() -> void:
	for card in drawn_cards:
		card.highlight_ruby_card()
		card.topaz = false
		card.emerald = false
		card.ruby = true
		card.sapphire = false
	big_ruby.global_position = Vector2(-100,-100)
	_on_big_ruby_mouse_exited()
	


func _on_next_button_mouse_entered() -> void:
	next_button.size.x += 12
	next_button.size.y += 6
	next_button.position.y -= 3
	next_button.position.x -= 6

func _on_next_button_mouse_exited() -> void:
	next_button.size.x -= 12
	next_button.size.y -= 6
	next_button.position.y += 3
	next_button.position.x += 6


func _on_exacuviate_mouse_entered() -> void:
	excavate_cards_button.size.x += 12
	excavate_cards_button.size.y += 6
	excavate_cards_button.position.y -= 3
	excavate_cards_button.position.x -= 6
	excavation_cost_label.global_position.y += 3
	excavation_cost_label.global_position.x += 6
	
func _on_exacuviate_mouse_exited() -> void:
	excavate_cards_button.size.x -= 12
	excavate_cards_button.size.y -= 6
	excavate_cards_button.position.y += 3
	excavate_cards_button.position.x += 6
	excavation_cost_label.global_position.y -= 3
	excavation_cost_label.global_position.x -= 6
