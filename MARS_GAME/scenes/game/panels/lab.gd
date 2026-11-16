extends PanelContainer
@onready var crew_list: VBoxContainer = $Body/CrewScroll/CrewList
@onready var repairs: HBoxContainer = $Body/RepairButtons
@onready var status: Label = $Body/DataStatus
@onready var auto: CheckButton = $Body/AutoData
@onready var message: Label = $Body/Message
var signature := ""

func _ready() -> void:
	auto.button_pressed = MarsSimulation.automated_data
	auto.toggled.connect(func(value: bool): MarsSimulation.set_automated_data(value))
	update_display()

func add_action(parent: Node, title: String, action: Callable) -> void:
	var b := Button.new()
	b.text = title
	b.custom_minimum_size.y = 32
	parent.add_child(b)
	b.pressed.connect(action)

func clear(parent: Node) -> void:
	for c in parent.get_children(): c.queue_free()

func _task(i: int, task: String, target: int = -1) -> void:
	if not MarsSimulation.assign_task(i, task, target):
		message.text = "Cannot start. Check location, energy or rover status."
	else:
		message.text = "Task assigned."
	signature = ""
	update_display()

func _idle(i: int) -> void:
	MarsSimulation.set_assignment(i, "LAB")
	signature = ""
	update_display()

func _automatic_repair(i: int) -> void:
	MarsSimulation.start_automatic_repair(i)
	signature = ""
	update_display()

func update_display() -> void:
	status.text = "PROCESSED: %.1f / %.0f GB     RAW DATA: %.1f GB" % [MarsSimulation.processed_gb, MarsSimulation.DATA_GOAL_GB, MarsSimulation.raw_data_gb]
	var snapshot := ""
	for h in MarsSimulation.humans: snapshot += str(h["assignment"]) + ":" + str(h["task"]) + ";"
	for r in MarsSimulation.rovers: snapshot += "%s:%d;" % [r["status"], int(r["health"])]
	if snapshot == signature: return
	signature = snapshot
	clear(crew_list)
	clear(repairs)
	for i in range(MarsSimulation.humans.size()):
		var h: Dictionary = MarsSimulation.humans[i]
		if h["assignment"] != "LAB": continue
		var row := HBoxContainer.new()
		crew_list.add_child(row)
		var title := Label.new()
		title.text = "%s (%d%%)" % [h["name"], int(h["energy"])]
		title.custom_minimum_size.x = 180
		row.add_child(title)
		add_action(row, "Process Data", _task.bind(i, "PROCESS DATA", -1))
		add_action(row, "Idle", _idle.bind(i))
		for ri in range(MarsSimulation.rovers.size()):
			if MarsSimulation.rovers[ri]["health"] < 100.0:
				add_action(row, "Repair Rover %d" % (ri+1), _task.bind(i, "REPAIR ROVER", ri))
	for ri in range(MarsSimulation.rovers.size()):
		if MarsSimulation.rovers[ri]["health"] < 100.0:
			add_action(repairs, "Auto-repair Rover %d" % (ri+1), _automatic_repair.bind(ri))
	if crew_list.get_child_count() == 0: message.text = "Assign astronauts to LAB from OPERATIONS."
