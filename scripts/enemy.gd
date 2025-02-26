@tool
class_name Enemy extends Node2D

@export var max_health: int = 100
@export var score: int = 0
@export var goal: int = 100
@onready var score_label = $score_label
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
var level = 5

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
	while score != 0:
		score -= 1
		goal -= 1
		set_goal_value(goal)
		set_score_value(score)
		await get_tree().create_timer(0.1).timeout

func resolve_attacks()-> void:

	for attack in chosen_attacks:
		if attack  == "chain":
			lock_random_card()
		if attack == "double_chain":
			lock_2_random_cards()
		if attack == "triple_chain":
			lock_3_random_cards()
		if attack == "shuffle":
			shuffle_all_cards_from_the_table()
		if attack == "freeze":
			freeze_jokers()
		if attack == "redeal":
			increase_the_cost_of_redeal()

	for attack_place in attack_places:
		attack_place.icon.texture = null
		
func prepare_new_attacks()-> void:
	choose_attacks()
	var i = 0
	for attack in chosen_attacks:
		if attack  == "chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/chain_debuff.png")
		if attack == "double_chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/double_chain_debuff.png")
		if attack == "triple_chain":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/tripple_chain_debuff.png")
		if attack == "shuffle":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/shuffle_a_stack_debuff.png")
		if attack == "freeze":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/freeze_debuff.png")
		if attack == "redeal":
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
			shuffle_all_cards_from_the_table()
		if attack == "freeze":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/freeze_debuff.png")
			freeze_jokers()
		if attack == "redeal":
			attack_places[i].icon.texture = load("res://sprites/debuff_icons/reroll_debuff.png")
			increase_the_cost_of_redeal()
		i += 1
		
func shuffle_all_cards_from_the_table()-> void:
	get_parent().redeal_cards()
	
func choose_attacks()-> void:
	var available_attacks = []
	chosen_attacks.clear()
	if level == 1:
		available_attacks = level_1_attacks.duplicate()
	if level == 2:
		available_attacks = level_2_attacks.duplicate()
	if level == 3:
		available_attacks = level_3_attacks.duplicate()
	if level == 4:
		available_attacks = level_4_attacks.duplicate()
	if level == 5:
		available_attacks = level_5_attacks.duplicate()
	
	available_attacks.shuffle()
	for i in range(0, level):
		chosen_attacks.append(available_attacks.pop_front())
	
	print(chosen_attacks) 

func remove_upcomming_attacks() -> void:
	pass
	
func freeze_jokers():
	get_parent().jokers_are_frozen = true
	
func shuffle_random_stack():
	var possible_stacks = 0
	for stack in get_parent().ui.stacks.get_children():
		if stack.cards_in_stack.size() > 1:
			possible_stacks += 1
	if possible_stacks == 0:
		return
	var random_number = randi_range(0, possible_stacks)
	for stack in get_parent().ui.stacks.get_children():
		if stack.cards_in_stack.size() > 1:
			if random_number == 0:
				print('shuffle this stack')
				pass
			else:
				random_number -= 1
				
func increase_the_cost_of_redeal():
	get_parent().redeal_cost += 1
	get_parent().redeal_cards_button.set_text(str(get_parent().redeal_cost))
	
func lock_random_card():
	var number_of_cards = get_parent().original_deck.card_collection.size()
	var random_number = randi() % number_of_cards + 1
	for stack in get_parent().ui.stacks.get_children():
		for card in stack.cards_in_stack:
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
			card.chains.hide()
			card.locked = false
		
func unlock_stacks():
	var i = 1
	while i <= 18:
		if get_parent().ui.stacks.array_of_stacks[i].locked == true:
			get_parent().ui.stacks.array_of_stacks[i].locked = false
			get_parent().ui.stacks.array_of_stacks[i].lock_sprite.visible = false
		i += 1
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_places = [attack_place_1, attack_place_2, attack_place_3, attack_place_4, attack_place_5]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
