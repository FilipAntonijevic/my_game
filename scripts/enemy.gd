@tool
class_name Enemy extends Node2D

@onready var score: int = 0
@onready var goal: int = 75
@onready var progress: int = 0
@onready var score_label = $score_label
@onready var progress_label = $progress_label
@onready var goal_label = $goal_label
@onready var visual_aid_label = $visual_aid_label

@onready var attack_place_1 = $DebuffPlace1
@onready var attack_place_2 = $DebuffPlace2
@onready var attack_place_3 = $DebuffPlace3
@onready var attack_place_4 = $DebuffPlace4
@onready var attack_place_5 = $DebuffPlace5

var attack_places: Array = []
var level_1_attacks: Array = ["chain", "chain", "shuffle", "redeal", "freeze"]
var level_2_attacks: Array = ["double_chain", "chain", "shuffle", "redeal", "freeze"]
var level_3_attacks: Array = ["double_chain", "double_chain", "chain", "shuffle", "redeal", "freeze"]
var level_4_attacks: Array = ["triple_chain", "double_chain", "double_chain", "shuffle", "redeal", "redeal", "freeze"]
var level_5_attacks: Array = ["triple_chain", "triple_chain", "double_chain", "double_chain", "shuffle", "redeal", "redeal", "freeze"]
var chosen_attacks: Array = []

func level_up()-> void:
	if goal > 25 and goal <= 100 and GameInfo.enemy_level == 0:
		GameInfo.enemy_level = 1 #level 1
		get_parent().update_coins(GameInfo.enemy_gold + 1)
	if goal >= 125 and goal <= 200 and GameInfo.enemy_level == 1:
		GameInfo.enemy_level = 2 # level 2
		get_parent().update_coins(GameInfo.enemy_gold + 1)
	if goal > 225 and goal <= 300 and GameInfo.enemy_level == 2:
		GameInfo.enemy_level = 3 # level 3
		get_parent().update_coins(GameInfo.enemy_gold + 1)
	if goal > 325 and goal <= 400 and GameInfo.enemy_level == 3:
		GameInfo.enemy_level = 4 # level 4
		get_parent().update_coins(GameInfo.enemy_gold + 1)
	if goal > 425 and goal <= 500 and GameInfo.enemy_level == 4:
		GameInfo.enemy_level = 5 # level 5
		get_parent().update_coins(GameInfo.enemy_gold + 1)
	
	
func set_score_value(_score: int):
	score = _score
	score_label.set_text(str(score))
	
func set_goal_value(new_goal: int):
	goal = new_goal
	goal_label.set_text(str(goal))
	
		
func set_visual_aid_label(aid: String):
	visual_aid_label.set_text(str(aid))

func reduce_goal_by_score_ammount():
		
	await get_tree().create_timer(0.5).timeout
	var initial_score := score
	if initial_score == 0:
		return
	
	var duration := 1.5 
	var wait_time := duration / initial_score
	
	while score > 0:
		score -= 1
		progress += 1
		update_progress_value()
		set_score_value(score)
		await get_tree().create_timer(wait_time).timeout

func update_progress_value():
	progress_label.set_text(str(progress))

func unfreeze_cards() -> void:
	if get_parent().jokers_are_frozen == false:
		for joker in get_parent().jokers.get_children():
			joker.set_modulate(Color(1,1,1,1))
			
func resolve_attacks()-> void:

	for attack in chosen_attacks:
		if attack == "chain":
			lock_random_card()
		if attack == "double_chain":
			lock_2_random_cards()
		if attack == "triple_chain":
			lock_3_random_cards()
		if attack == "shuffle":
			shuffle_a_random_stack()
			#shuffle_all_cards_from_the_table()
		if attack == "freeze":
			freeze_jokers()
		if attack == "redeal":
			increase_the_cost_of_redeal()

	for attack_place in attack_places:
		attack_place.icon.texture = null
		attack_place.debuff = ""

func prepare_new_attacks()-> void:
	choose_attacks()
	var i = 0
	for attack in chosen_attacks:
		if attack  == "chain":
			attack_places[i].debuff = "chain"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/chain_debuff.png")
		if attack == "double_chain":
			attack_places[i].debuff = "double_chain"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/double_chain_debuff.png")
		if attack == "triple_chain":
			attack_places[i].debuff = "triple_chain"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/tripple_chain_debuff.png")
		if attack == "shuffle":
			attack_places[i].debuff = "shuffle"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/shuffle_a_stack_debuff.png")
		if attack == "freeze":
			attack_places[i].debuff = "freeze"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/freeze_debuff.png")
		if attack == "redeal":
			attack_places[i].debuff = "redeal"
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/reroll_debuff.png")
		i += 1

func ability():
	choose_attacks()
	for attack_place in attack_places:
		attack_place.icon.texture = null
	var i = 0
	for attack in chosen_attacks:
		if attack  == "chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/chain_debuff.png")
			lock_random_card()
		if attack == "double_chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/double_chain_debuff.png")
			lock_2_random_cards()
		if attack == "triple_chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/tripple_chain_debuff.png")
			lock_3_random_cards()
		if attack == "shuffle":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/shuffle_a_stack_debuff.png")
			shuffle_a_random_stack()
		if attack == "freeze":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/freeze_debuff.png")
			freeze_jokers()
		if attack == "redeal":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/reroll_debuff.png")
			increase_the_cost_of_redeal()
		i += 1

func shuffle_a_random_stack():
	var valid_stacks := []
	for stack in get_parent().ui.stacks.get_children():
		if stack.cards_in_stack.size() > 1:
			valid_stacks.append(stack)
	
	if valid_stacks.size() == 0:
		return # nema nijedan stack sa više od jedne karte
	
	var random_stack = valid_stacks[randi_range(0, valid_stacks.size() - 1)]
	var cards = random_stack.cards_in_stack
	for i in range(cards.size() - 1, 0, -1):
		var j = randi_range(0, i)
		var temp = cards[i]
		cards[i] = cards[j]
		cards[j] = temp
	
	random_stack.reposition_cards()

func shuffle_all_cards_from_the_table()-> void:
	var jokers =  get_parent().jokers
	var can_shuffle = true
	for joker_place in jokers.get_children():
		if joker_place.joker != null:
			if joker_place.joker.effect.name == "Joker_5_spades":
				can_shuffle = false
	
	if can_shuffle:
		get_parent().redeal_cards()


func choose_attacks()-> void:
	var available_attacks = []
	chosen_attacks.clear()
	if GameInfo.enemy_level == 1:
		available_attacks = level_1_attacks.duplicate()
	if GameInfo.enemy_level == 2:
		available_attacks = level_2_attacks.duplicate()
	if GameInfo.enemy_level == 3:
		available_attacks = level_3_attacks.duplicate()
	if GameInfo.enemy_level == 4:
		available_attacks = level_4_attacks.duplicate()
	if GameInfo.enemy_level == 5:
		available_attacks = level_5_attacks.duplicate()
	
	available_attacks.shuffle()
	for i in range(0, GameInfo.enemy_level):
		chosen_attacks.append(available_attacks.pop_front())
	 

func remove_upcomming_attacks() -> void:
	chosen_attacks.clear()
	for attack_place in attack_places:
		attack_place.icon.texture = null
		attack_place.debuff = ""
	
func freeze_jokers():
	get_parent().freeze_jokers()

func increase_the_cost_of_redeal():
	get_parent().redeal_cost += 1
	get_parent().check_if_redeal_cards_button_should_turn_into_give_up_button()

	
func lock_random_card():
	var number_of_cards = get_parent().original_deck.card_collection.size()
	var random_number = randi() % number_of_cards + 1
	for stack in get_parent().ui.stacks.get_children():
		for card in stack.cards_in_stack:
			if card != null:
				random_number -= 1
				if random_number == 0:
					if card.locked :
						lock_random_card()
					else:
						if card.topaz == false:
							card.locked = true
							card.chains.show()
						else:
							pass #animacija lomljenja lanaca
func lock_2_random_cards():
	lock_random_card()
	lock_random_card()
	
func lock_3_random_cards():
	lock_random_card()
	lock_random_card()
	lock_random_card()

	
func lock_random_stack():
	var random_number = randi() % 18 + 1
	get_parent().ui.stacks.array_of_stacks[random_number].locked = true
	get_parent().ui.stacks.array_of_stacks[random_number].lock_sprite.visible = true

func unlock_cards():
	for stack in get_parent().ui.stacks.get_children():
		for card in stack.cards_in_stack:
			if card != null:
				card.chains.hide()
				card.locked = false
		
func unlock_stacks():
	var i = 1
	while i <= 18:
		if get_parent().ui.stacks.array_of_stacks[i].locked == true:
			get_parent().ui.stacks.array_of_stacks[i].locked = false
			get_parent().ui.stacks.array_of_stacks[i].lock_sprite.visible = false
		i += 1
		
func _ready() -> void:
	attack_places = [attack_place_1, attack_place_2, attack_place_3, attack_place_4, attack_place_5]
