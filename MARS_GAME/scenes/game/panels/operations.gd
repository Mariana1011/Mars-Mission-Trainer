extends PanelContainer
const CrewCard = preload("res://scenes/game/cards/crew_card.tscn")
const RoverCard = preload("res://scenes/game/cards/rover_card.tscn")
@onready var crew_list: VBoxContainer = $Body/Columns/CrewCol/CrewScroll/CrewList
@onready var rover_list: VBoxContainer = $Body/Columns/RoverCol/RoverScroll/RoverList

func _ready() -> void:
	for i in range(MarsSimulation.humans.size()):
		var card = CrewCard.instantiate()
		crew_list.add_child(card)
		card.configure(i)
	for i in range(MarsSimulation.rovers.size()):
		var card = RoverCard.instantiate()
		rover_list.add_child(card)
		card.configure(i)

func update_display() -> void:
	for card in crew_list.get_children(): card.update_display()
	for card in rover_list.get_children(): card.update_display()
