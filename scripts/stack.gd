class_name Stack extends Node2D

var cards_in_stack: Array = []
var touched_cards: Array = []
var current_selected_card_index: int = -1

var is_dragging: bool = false

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
#@onready var card_scene: PackedScene = preload("res://scenes/card.tscn")

signal mouse_entered_stack(stack: Stack)
signal mouse_exited_stack(stack: Stack)

func connect_signals(card: Card):
	if not card.mouse_entered_card.is_connected(handle_card_touched):
		card.mouse_entered_card.connect(handle_card_touched)
	if not card.mouse_exited_card.is_connected(handle_card_untouched):
		card.mouse_exited_card.connect(handle_card_untouched)
	
func add_card(card: Card) -> bool:
	if check_if_card_can_be_added():
		cards_in_stack.push_back(card)
		add_child(card)
		card = connect_signals(card)
		reposition_cards()
		return true
	return false
	
func remove_card(card: Card):
	cards_in_stack.remove_at(cards_in_stack.find(card))
	remove_child(card)
	reposition_cards()

func remove_card_from_table(index: int):
	if index < cards_in_stack.size():
		var removing_card = cards_in_stack[index]
		cards_in_stack.remove_at(index)
		remove_child(removing_card)
		reposition_cards()
		

func remove_card_from_deck_and_table(deck: Deck, index: int):
	if index < cards_in_stack.size():
		var removing_card = cards_in_stack[index]
		if check_if_card_can_be_placed_on_pile(removing_card):
			cards_in_stack.remove_at(index)
			remove_child(removing_card)
			deck.remove_card_by_value(removing_card)
			place_card_on_according_pile(removing_card)
			update_card_position(removing_card,0)
			removing_card.unhighlight()
			reposition_cards()
			
func remove_card_from_deck_and_table_via_card(deck: Deck, removing_card: Card):

	if check_if_card_can_be_placed_on_pile(removing_card):
		print('moze')
		cards_in_stack.remove_at(cards_in_stack.find(removing_card))
		remove_child(removing_card)
		deck.remove_card_by_value(removing_card)
		place_card_on_according_pile(removing_card)
		update_card_position(removing_card,0)
		removing_card.unhighlight()
		reposition_cards()
			
func check_if_card_can_be_placed_on_pile(card: Card) -> bool:
	var spades_pile_value = get_parent().get_parent().spades_pile_value
	var diamonds_pile_value = get_parent().get_parent().diamonds_pile_value
	var clubs_pile_value = get_parent().get_parent().clubs_pile_value
	var hearts_pile_value = get_parent().get_parent().hearts_pile_value
		
	if card.card_suit == "spades" && (spades_pile_value + 1) == card.card_value:
		get_parent().get_parent().spades_pile_value += 1
		return true
	if card.card_suit == "diamonds" && (diamonds_pile_value + 1) == card.card_value:
		get_parent().get_parent().diamonds_pile_value += 1
		return true
	if card.card_suit == "clubs" && (clubs_pile_value + 1) == card.card_value:
		get_parent().get_parent().clubs_pile_value += 1
		return true
	if card.card_suit == "hearts" && (hearts_pile_value + 1) == card.card_value:
		get_parent().get_parent().hearts_pile_value += 1
		return true
	return false
	
func place_card_on_according_pile(card: Card):
		var spades_pile = get_parent().get_parent().spades_pile
		var diamonds_pile = get_parent().get_parent().diamonds_pile
		var clubs_pile = get_parent().get_parent().clubs_pile
		var hearts_pile = get_parent().get_parent().hearts_pile
		
		if card.card_suit == "spades":
			spades_pile.add_child(card)
		if card.card_suit == "diamonds":
			diamonds_pile.add_child(card)
		if card.card_suit == "clubs":
			clubs_pile.add_child(card)
		if card.card_suit == "hearts":
			hearts_pile.add_child(card)


func reposition_cards():
	var x: float = 0
	for card in cards_in_stack:
		update_card_position(card, x)
		x -= 13
		

func update_card_position(card: Node2D, x: float):
	card.set_position(get_card_position(x))
	

func get_card_position(x: float) -> Vector2:
	var y: float = 0
	return Vector2(int(x),int(y))
	
func check_if_card_can_be_added() -> bool:
	if cards_in_stack.size() >= 3:
		return false
	else:
		return true

func handle_card_touched(card: Card):
	touched_cards.push_back(card)


func handle_card_untouched(card: Card):
	var index: int = touched_cards.find(card)
	if index >= 0:
		touched_cards.remove_at(index)

		
func check_if_card_is_on_top_of_the_stack(card_index: int) -> bool:
	if card_index == 2:
		return true
	if card_index == 1 && cards_in_stack.size() == 2:
		return true
	if card_index == 0 && cards_in_stack.size() == 1:
		return true
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for card in cards_in_stack:
		current_selected_card_index = -1
		card.unhighlight()
		
	if !touched_cards.is_empty():
		var highest_touched_index: int = -1
		
		for touched_card in touched_cards:
			highest_touched_index = max(highest_touched_index, cards_in_stack.find(touched_card))
		
		if highest_touched_index >= 0 && highest_touched_index < cards_in_stack.size():
			cards_in_stack[highest_touched_index].highlight()
			current_selected_card_index = highest_touched_index
			set_current_card_index(current_selected_card_index)
			
func set_current_card_index(value: int):
	var ui_node = get_parent().get_parent()  
	if ui_node:
		ui_node.current_selected_card_for_movement_index = value

func _on_area_2d_mouse_entered() -> void:
	mouse_entered_stack.emit(self)
	if cards_in_stack.size() == 4: #ovo je ako dodam da moze 4 karte na stack ikad
		update_card_position(cards_in_stack[3], -25) #npr
		update_card_position(cards_in_stack[1], -13)
		update_card_position(cards_in_stack[0], 0)
	if cards_in_stack.size() == 3:
		update_card_position(cards_in_stack[1], -3)
		update_card_position(cards_in_stack[0], 20)
	if cards_in_stack.size() == 2:
		update_card_position(cards_in_stack[0], 13)
	set_collision_shape_properties(114,170,-5,0)


func _on_area_2d_mouse_exited() -> void:
	mouse_exited_stack.emit()
	if cards_in_stack.size() == 4: #ovo je ako dodam da moze 4 karte na stack ikad
		update_card_position(cards_in_stack[3], -35) #npr
		update_card_position(cards_in_stack[1], -12)
		update_card_position(cards_in_stack[0], 0)
	if cards_in_stack.size() == 3:
		update_card_position(cards_in_stack[1], -12)
		update_card_position(cards_in_stack[0], 0)
	if cards_in_stack.size() == 2:
		update_card_position(cards_in_stack[0], 0)
	set_collision_shape_properties(114,130,-25,0)
	#TODO da napravim da i za 2 karte radi pixel perfect a ne ovako odokativno (i za 4 ako dodam to)
	
func set_collision_shape_properties(height: float, width: float, x: float, y: float):

	var rect_shape = collision_shape.shape as RectangleShape2D
	collision_shape.position = Vector2(x, y)
	if is_dragging == true:
		rect_shape.extents = Vector2(15 + width / 2, 15 + height / 2)
	else:
		rect_shape.extents = Vector2(width / 2, height / 2)

func set_is_dragging(is_dragging_ui: bool):
	is_dragging = is_dragging_ui