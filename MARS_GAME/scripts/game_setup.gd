extends Node
## Selection state ONLY. No power simulation runs in the pre-game setup.
signal setup_changed

const MIN_HUMANS: int = 2
const MAX_HUMANS: int = 5
const MIN_ROVERS: int = 1
const MAX_ROVERS: int = 3

# Nuclear fission and batteries are always installed.
var nuclear_fission: bool = true
var batteries: bool = true
var photovoltaic: bool = false
var wind_energy: bool = false
var humans: int = MIN_HUMANS
var rovers: int = MIN_ROVERS
var prepared: bool = false

func reset_selection() -> void:
	nuclear_fission = true
	batteries = true
	photovoltaic = false
	wind_energy = false
	humans = MIN_HUMANS
	rovers = MIN_ROVERS
	prepared = false
	setup_changed.emit()

func set_optional(module_id: String, enabled: bool) -> void:
	match module_id:
		"photovoltaic": photovoltaic = enabled
		"wind_energy": wind_energy = enabled
		_: return
	prepared = false
	setup_changed.emit()

func set_count(kind: String, value: int) -> void:
	match kind:
		"humans": humans = clampi(value, MIN_HUMANS, MAX_HUMANS)
		"rovers": rovers = clampi(value, MIN_ROVERS, MAX_ROVERS)
		_: return
	prepared = false
	setup_changed.emit()

func validate_selection() -> String:
	if not nuclear_fission or not batteries:
		return "The reactor and battery bank are required."
	if humans < MIN_HUMANS or humans > MAX_HUMANS:
		return "Choose between 2 and 5 humans."
	if rovers < MIN_ROVERS or rovers > MAX_ROVERS:
		return "Choose between 1 and 3 rovers."
	return ""

func get_selection() -> Dictionary:
	return {
		"energy": {
			"nuclear_fission": true,
			"batteries": true,
			"photovoltaic": photovoltaic,
			"wind_energy": wind_energy
		},
		"operations": {"humans": humans, "rovers": rovers}
	}

func get_summary() -> String:
	var energy: String = "Nuclear Fission, Batteries"
	if photovoltaic: energy += ", Photovoltaic"
	if wind_energy: energy += ", Wind"
	return "ENERGY\n" + energy + "\n\nOPERATIONS\nHumans: %d  |  Rovers: %d" % [humans, rovers]
