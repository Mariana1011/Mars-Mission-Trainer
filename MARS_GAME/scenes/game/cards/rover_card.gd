extends PanelContainer
## Editable rover card; status text remains horizontal.
var rover_index := -1
@onready var name_status: Label = $Body/NameStatus
@onready var meter: ProgressBar = $Body/Meter

func _ready() -> void:
	$Body/Actions/Charge.pressed.connect(_order.bind("charge"))
	$Body/Actions/Collect.pressed.connect(_order.bind("collect"))
	$Body/Actions/Stop.pressed.connect(_order.bind("stop"))

func configure(index: int) -> void:
	rover_index = index
	update_display()

func _order(order: String) -> void:
	MarsSimulation.rover_command(rover_index, order)
	update_display()

func update_display() -> void:
	if rover_index < 0 or rover_index >= MarsSimulation.rovers.size(): return
	var rover: Dictionary = MarsSimulation.rovers[rover_index]
	name_status.text = "%s  |  Battery: %d%%  |  Health: %d%%  |  %s" % [rover["name"], roundi(rover["battery"]), roundi(rover["health"]), rover["status"]]
	meter.value = float(rover["battery"])
