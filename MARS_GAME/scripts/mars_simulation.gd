extends Node
## Gameplay parameters are illustrative; electrical quantities use kW/kWh and resources kg/L.
signal changed
signal mission_finished
const SOL_MINUTES: float = 1479.0
const MISSION_SOLS: int = 6
const DATA_GOAL_GB: float = 150.0
const HUMAN_NAMES: Array[String] = ["Tom", "Ana", "Max", "Sergio", "Wanda"]
const DUTIES: Array[String] = ["REST", "ENERGY", "LIFE SUPPORT", "LAB"]
const ROVER_READY = "READY"
const ROVER_SERVICE = "IN MAINTENANCE"
const ROVER_NEEDS_SERVICE = "NEEDS MAINTENANCE"
const ROVER_CHARGING = "CHARGING"
const ROVER_COLLECTING = "COLLECTING DATA"
const LIFE_DEVICES: Array[String] = ["oxygen", "water", "temperature"]
const POWER_DEVICES: Array[String] = ["fission", "solar", "wind"]

var initialized := false
var paused := false
var finished := false
var outcome := ""
var sol_number := 1
var minute_of_sol := 480.0
var time_scale := 10.0
var humans: Array[Dictionary] = []
var rovers: Array[Dictionary] = []
var devices: Dictionary = {}
var raw_data_gb := 0.0
var processed_gb := 0.0
var battery_capacity_kwh := 300.0
var battery_kwh := 210.0
var generation_kw := 0.0
var demand_kw := 0.0
var supplied_fraction := 1.0
var oxygen_kg := 40.0
var water_l := 220.0
var temperature_f := 70.0
var experiment_hours := 0.0
var data_generated_total := 0.0
var crew_work_hours := 0.0
var failures_total := 0
var repairs_total := 0
var total_unserved_kwh := 0.0
var automated_data := false
var automatic_repair_target := -1
var automatic_repair_progress := 0.0
var life_downtime_hours := 0.0
var warning := ""
var last_report: Dictionary = {}
var rng := RandomNumberGenerator.new()
var previous_oxygen := 40.0
var previous_water := 220.0

func start_from_pregame() -> void:
	rng.randomize()
	humans.clear()
	rovers.clear()
	for i in range(GameSetup.humans):
		humans.append({"name": HUMAN_NAMES[i], "energy": 100.0, "assignment": "REST", "task": "", "task_target": -1})
	for i in range(GameSetup.rovers):
		rovers.append({"name":"Rover %d" % (i+1), "battery":100.0,"health":100.0,"status":ROVER_READY})
	devices = {"fission":true,"solar":bool(GameSetup.photovoltaic),"wind":bool(GameSetup.wind_energy),"oxygen":true,"water":true,"temperature":true}
	sol_number=1
	minute_of_sol=480.0
	raw_data_gb=0.0
	processed_gb=0.0
	battery_kwh=210.0
	generation_kw=0.0
	demand_kw=0.0
	supplied_fraction=1.0
	oxygen_kg=40.0
	water_l=220.0
	temperature_f=70.0
	previous_oxygen=oxygen_kg
	previous_water=water_l
	experiment_hours=0.0
	data_generated_total=0.0
	crew_work_hours=0.0
	failures_total=0
	repairs_total=0
	total_unserved_kwh=0.0
	automated_data=false
	automatic_repair_target=-1
	automatic_repair_progress=0.0
	life_downtime_hours=0.0
	warning=""
	last_report={}
	finished=false
	outcome=""
	paused=false
	initialized=true
	changed.emit()

func _process(delta:float) -> void:
	if not initialized or paused or finished: return
	# Fixed small simulation steps prevent skipping past energy limits on slow frames.
	var remaining:float = minf(delta*time_scale,60.0)
	while remaining > 0.001 and not finished:
		var step:float = minf(remaining,5.0)
		_advance(step/60.0)
		remaining -= step
	changed.emit()

func _advance(dt_hours:float) -> void:
	minute_of_sol += dt_hours*60.0
	if minute_of_sol >= SOL_MINUTES:
		minute_of_sol -= SOL_MINUTES
		sol_number += 1
		if sol_number > MISSION_SOLS:
			_complete("MISSION COMPLETE")
			return
	# Nuclear availability is a gameplay premise; wind depends on weather, solar on daylight.
	var solar_phase:float = (minute_of_sol/SOL_MINUTES)*TAU
	var sunlight:float = maxf(0.0,sin(solar_phase))
	generation_kw = (40.0 if devices["fission"] else 0.0)
	if devices["solar"]: generation_kw += 20.0*sunlight
	if devices["wind"]: generation_kw += 0.3 + 0.2*(0.5+0.5*sin(solar_phase*2.0))
	var crew_active:int=0
	for h in humans:
		if str(h["task"]) != "": crew_active+=1
	demand_kw = 11.5 + float(crew_active)*0.35 # life support, lights and occupied workstations
	var life_power_ok:bool = bool(devices["oxygen"]) and bool(devices["water"]) and bool(devices["temperature"])
	if automated_data: demand_kw += 9.0
	if automatic_repair_target >= 0: demand_kw += 7.0
	for r in rovers:
		if r["status"] == ROVER_CHARGING: demand_kw += 1.2
	# Batteries charge with surplus and discharge when demand exceeds supply, max 25 kW.
	var power_gap:float = demand_kw-generation_kw
	var served_kw:float = generation_kw
	if power_gap > 0.0:
		var discharge_kw:float = minf(minf(power_gap,25.0),battery_kwh/dt_hours)
		battery_kwh -= discharge_kw*dt_hours
		served_kw += discharge_kw
	else:
		var charge_kw:float = minf(minf(-power_gap,25.0),(battery_capacity_kwh-battery_kwh)/dt_hours)
		battery_kwh += charge_kw*dt_hours*0.90
	battery_kwh=clampf(battery_kwh,0.0,battery_capacity_kwh)
	supplied_fraction = clampf(served_kw/maxf(0.01,demand_kw),0.0,1.0)
	total_unserved_kwh += maxf(0.0,demand_kw-served_kw)*dt_hours
	# Crew drains only when doing an assigned job, not just being in a module.
	for i in range(humans.size()):
		var h:Dictionary=humans[i]
		if str(h["task"]) == "":
			h["energy"]=minf(100.0,float(h["energy"])+12.0*dt_hours)
		else:
			var rate:float=9.0 if str(h["task"]) == "PROCESS DATA" else 11.0
			h["energy"]=maxf(0.0,float(h["energy"])-rate*dt_hours)
			crew_work_hours+=dt_hours
			if h["task"] == "PROCESS DATA" and supplied_fraction>0.8:
				_process_raw(1.2*dt_hours)
			elif h["task"] == "REPAIR ROVER":
				var ri:int=int(h["task_target"])
				if ri >= 0 and ri < rovers.size():
					var r:Dictionary=rovers[ri]
					if r["status"] != ROVER_COLLECTING:
						r["status"]=ROVER_SERVICE
						r["health"]=minf(100.0,float(r["health"])+28.0*dt_hours*supplied_fraction)
						rovers[ri]=r
						if float(r["health"])>=100.0:
							r["status"]=ROVER_READY
							rovers[ri]=r
							h["task"]=""
							repairs_total+=1
			elif h["task"] == "REPAIR SYSTEM":
				var target:String=str(h.get("device",""))
				if devices.has(target) and not devices[target]:
					h["repair_progress"]=float(h.get("repair_progress",0.0))+dt_hours*supplied_fraction
					if float(h["repair_progress"])>=2.0:
						devices[target]=true
						h["task"]=""
						h["repair_progress"]=0.0
						repairs_total+=1
			elif h["task"] == "MONITOR" and supplied_fraction > 0.7:
				experiment_hours+=dt_hours
			if float(h["energy"])<=0.0:
				h["task"]=""
				h["assignment"]="REST"
		humans[i]=h
	# Automated alternatives draw more power and do not need a human.
	if automated_data and supplied_fraction>0.8:
		_process_raw(2.6*dt_hours)
	if automatic_repair_target >= 0 and supplied_fraction>0.8:
		var idx:int=automatic_repair_target
		if idx < rovers.size():
			var ar:Dictionary=rovers[idx]
			if ar["status"] != ROVER_COLLECTING:
				ar["status"]=ROVER_SERVICE
				ar["health"]=minf(100.0,float(ar["health"])+50.0*dt_hours)
				rovers[idx]=ar
				if float(ar["health"])>=100.0:
					ar["status"]=ROVER_READY
					rovers[idx]=ar
					automatic_repair_target=-1
					repairs_total+=1
	# Rovers gather RAW data only. The progress bar is processed data.
	for i in range(rovers.size()):
		var rover:Dictionary=rovers[i]
		match rover["status"]:
			ROVER_COLLECTING:
				rover["battery"]=maxf(0.0,float(rover["battery"])-14.0*dt_hours)
				rover["health"]=maxf(0.0,float(rover["health"])-1.8*dt_hours)
				var gathered:float=2.0*dt_hours
				raw_data_gb=minf(300.0,raw_data_gb+gathered)
				data_generated_total+=gathered
				if float(rover["health"])<=30.0: rover["status"]=ROVER_NEEDS_SERVICE
				elif float(rover["battery"])<=12.0: rover["status"]=ROVER_READY
			ROVER_CHARGING:
				if supplied_fraction>0.7:
					rover["battery"]=minf(100.0,float(rover["battery"])+25.0*dt_hours)
					if float(rover["battery"])>=100.0:
						rover["status"]=ROVER_READY if float(rover["health"])>30.0 else ROVER_NEEDS_SERVICE
		rovers[i]=rover
	# Simplified life support reserves, with crew-scaled consumption.
	oxygen_kg=maxf(0.0,oxygen_kg-float(humans.size())*0.035*dt_hours)
	water_l=maxf(0.0,water_l-float(humans.size())*0.2*dt_hours)
	if devices["oxygen"] and supplied_fraction>0.75: oxygen_kg=minf(90.0,oxygen_kg+0.26*dt_hours*supplied_fraction)
	if devices["water"] and supplied_fraction>0.75: water_l=minf(450.0,water_l+1.4*dt_hours*supplied_fraction)
	var target_temp:float = 70.0 if devices["temperature"] and supplied_fraction>0.75 else 35.0
	temperature_f=move_toward(temperature_f,target_temp,(3.0 if target_temp==70.0 else 2.0)*dt_hours)
	if not life_power_ok: life_downtime_hours+=dt_hours
	# Failure chances per SOL: solar high, wind lower. Optional sources only fail when installed.
	for key in POWER_DEVICES:
		if not devices[key]: continue
		var chance:float=0.0
		match key:
			"solar": chance=0.20
			"wind": chance=0.07
			"fission": chance=0.015
		if rng.randf() < chance*dt_hours/(SOL_MINUTES/60.0):
			devices[key]=false
			failures_total+=1
			warning="System failure: %s. Assign a crew member in ENERGY." % key.to_upper()
	for key in LIFE_DEVICES:
		if devices[key] and rng.randf()<0.035*dt_hours/(SOL_MINUTES/60.0):
			devices[key]=false
			failures_total+=1
			warning="Life support failure: %s. Assign a crew member for repair." % key.to_upper()
	if oxygen_kg<=0.0 or water_l<=0.0 or temperature_f < 32.0:
		_complete("LIFE SUPPORT FAILURE")

func _process_raw(amount:float) -> void:
	var taken:float=minf(minf(raw_data_gb,amount),DATA_GOAL_GB-processed_gb)
	raw_data_gb-=taken
	processed_gb+=taken

func set_assignment(index:int,duty:String) -> void:
	if index<0 or index>=humans.size() or not DUTIES.has(duty): return
	var h:Dictionary=humans[index]
	if duty!="REST" and float(h["energy"])<10.0: return
	h["assignment"]=duty
	h["task"]=""
	h["task_target"]=-1
	h["repair_progress"]=0.0
	humans[index]=h
	changed.emit()

func assign_task(index:int,task:String,target:int=-1,device:String="") -> bool:
	if index<0 or index>=humans.size() or finished: return false
	var h:Dictionary=humans[index]
	if h["assignment"]=="REST" or float(h["energy"])<10.0: return false
	if task=="PROCESS DATA" and h["assignment"]!="LAB": return false
	if task=="REPAIR ROVER" and h["assignment"]!="LAB": return false
	if task=="REPAIR SYSTEM":
		if not (h["assignment"]=="ENERGY" or h["assignment"]=="LIFE SUPPORT"): return false
		if not devices.has(device) or devices[device]: return false
		if h["assignment"]=="ENERGY" and not POWER_DEVICES.has(device): return false
		if h["assignment"]=="LIFE SUPPORT" and not LIFE_DEVICES.has(device): return false
	if task=="REPAIR ROVER":
		if target<0 or target>=rovers.size() or rovers[target]["status"]==ROVER_COLLECTING: return false
	if not ["PROCESS DATA","REPAIR ROVER","REPAIR SYSTEM","MONITOR"].has(task): return false
	h["task"]=task
	h["task_target"]=target
	h["device"]=device
	h["repair_progress"]=0.0
	humans[index]=h
	changed.emit()
	return true

func set_automated_data(enabled:bool) -> void:
	automated_data=enabled
	changed.emit()

func start_automatic_repair(index:int) -> bool:
	if automatic_repair_target>=0 or index<0 or index>=rovers.size(): return false
	if rovers[index]["status"]==ROVER_COLLECTING: return false
	automatic_repair_target=index
	changed.emit()
	return true

func rover_command(index:int,command:String) -> void:
	if index<0 or index>=rovers.size() or finished: return
	var r:Dictionary=rovers[index]
	match command:
		"charge":
			if r["status"]==ROVER_COLLECTING or r["status"]==ROVER_SERVICE: return
			r["status"]=ROVER_CHARGING
		"collect":
			if r["status"]!=ROVER_READY or float(r["battery"])<25.0 or float(r["health"])<=30.0: return
			r["status"]=ROVER_COLLECTING
		"stop":
			if r["status"]!=ROVER_COLLECTING: return
			r["status"]=ROVER_READY if float(r["health"])>30.0 else ROVER_NEEDS_SERVICE
		_: return
	rovers[index]=r
	changed.emit()

func _complete(reason:String) -> void:
	finished=true
	paused=true
	outcome=reason
	var data_score:float=clampf(processed_gb/DATA_GOAL_GB,0.0,1.0)
	var life_score:float=1.0-clampf(life_downtime_hours/(MISSION_SOLS*SOL_MINUTES/60.0),0.0,1.0)
	var repair_score:float=float(repairs_total)/float(maxi(1,failures_total))
	var power_score:float=1.0-clampf(total_unserved_kwh/1500.0,0.0,1.0)
	var score:int=roundi(100.0*(0.45*data_score+0.30*life_score+0.15*power_score+0.10*clampf(repair_score,0.0,1.0)))
	last_report={"score":score,"data":processed_gb,"raw":raw_data_gb,"repairs":repairs_total,"failures":failures_total,"unserved":total_unserved_kwh,"oxygen":oxygen_kg,"water":water_l,"temperature":temperature_f,"reason":reason}
	mission_finished.emit()
	changed.emit()

func format_time() -> String:
	var t:int=int(minute_of_sol)
	return "%02d:%02d" % [int(t/60),t%60]
func assigned_count(duty:String) -> int:
	var count:int=0
	for h in humans:
		if h["assignment"]==duty: count+=1
	return count
func busy_count(duty:String) -> int:
	var count:int=0
	for h in humans:
		if h["assignment"]==duty and h["task"]!="": count+=1
	return count
