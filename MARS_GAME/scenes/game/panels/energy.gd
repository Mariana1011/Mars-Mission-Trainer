extends PanelContainer
@onready var crew_list: VBoxContainer = $Body/CrewScroll/CrewList
@onready var metrics: Label = $Body/Metrics
@onready var devices: Label = $Body/Devices
@onready var message: Label = $Body/Message
var signature := ""

func _task(index:int, task:String, target:String="") -> void:
	if not MarsSimulation.assign_task(index,task,-1,target): message.text = "Task unavailable."
	else: message.text = "Work assigned."
	signature = ""
	update_display()

func _idle(index:int) -> void:
	MarsSimulation.set_assignment(index,"ENERGY")
	signature = ""
	update_display()

func update_display() -> void:
	metrics.text = "GENERATING: %.1f kW   |   DEMAND: %.1f kW   |   BATTERY: %.1f / 300 kWh" % [MarsSimulation.generation_kw,MarsSimulation.demand_kw,MarsSimulation.battery_kwh]
	var power_names: Array[String] = ["fission"]
	if GameSetup.photovoltaic: power_names.append("solar")
	if GameSetup.wind_energy: power_names.append("wind")
	var device_text := ""
	for key in power_names: device_text += "%s: %s     " % [key.to_upper(),"ONLINE" if MarsSimulation.devices[key] else "DAMAGED"]
	devices.text = device_text
	var snapshot := device_text
	for h in MarsSimulation.humans: snapshot += str(h["assignment"]) + ":" + str(h["task"]) + ";"
	if snapshot == signature: return
	signature = snapshot
	for c in crew_list.get_children(): c.queue_free()
	for i in range(MarsSimulation.humans.size()):
		var h:Dictionary = MarsSimulation.humans[i]
		if h["assignment"] != "ENERGY": continue
		var row := HBoxContainer.new()
		crew_list.add_child(row)
		var label := Label.new()
		label.text = str(h["name"])
		label.custom_minimum_size.x = 155
		row.add_child(label)
		for option in ["Monitor", "Idle"]:
			var b := Button.new()
			b.text = option
			row.add_child(b)
			if option == "Idle": b.pressed.connect(_idle.bind(i))
			else: b.pressed.connect(_task.bind(i,"MONITOR",""))
		for key in power_names:
			if not MarsSimulation.devices[key]:
				var b := Button.new()
				b.text = "Repair " + key
				row.add_child(b)
				b.pressed.connect(_task.bind(i,"REPAIR SYSTEM",key))
