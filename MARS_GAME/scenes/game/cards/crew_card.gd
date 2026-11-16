extends PanelContainer
## Editable card: open crew_card.tscn to change the layout.
var crew_index: int = -1
var updating := false
@onready var name_status: Label = $Body/NameStatus
@onready var meter: ProgressBar = $Body/Meter
@onready var assignment: OptionButton = $Body/Assignment

func _ready() -> void:
	for duty in MarsSimulation.DUTIES:
		assignment.add_item(duty.capitalize())
	assignment.item_selected.connect(_choose)

func configure(index: int) -> void:
	crew_index = index
	update_display()

func _choose(item: int) -> void:
	if updating: return
	MarsSimulation.set_assignment(crew_index, MarsSimulation.DUTIES[item])
	update_display()

func update_display() -> void:
	if crew_index < 0 or crew_index >= MarsSimulation.humans.size(): return
	var h: Dictionary = MarsSimulation.humans[crew_index]
	name_status.text = "%s  |  Energy: %d%%  |  %s" % [h["name"], roundi(h["energy"]), "RESTING" if h["task"] == "" else h["task"]]
	meter.value = float(h["energy"])
	updating = true
	assignment.select(MarsSimulation.DUTIES.find(str(h["assignment"])))
	updating = false
