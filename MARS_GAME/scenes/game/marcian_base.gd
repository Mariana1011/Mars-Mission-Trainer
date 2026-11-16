extends Control
## Four editable Godot panels, HUD, music toggle and reusable pause/report scene.
const DESIGN_SIZE := Vector2(1678, 937)
const PANEL_SCENES := {
	"LAB": preload("res://scenes/game/panels/lab.tscn"),
	"ENERGY": preload("res://scenes/game/panels/energy.tscn"),
	"LIFE SUPPORT": preload("res://scenes/game/panels/life_support.tscn"),
	"OPERATIONS": preload("res://scenes/game/panels/operations.tscn")
}
const MODAL_SCENE = preload("res://scenes/game/panels/mission_modal.tscn")
@onready var art: Control = $ArtSpace
@onready var slot: Control = $ArtSpace/HUD/ModuleSlot
@onready var modal_slot: Control = $ArtSpace/HUD/Modal
@onready var sol_label: Label = $ArtSpace/HUD/SolNumber
@onready var clock_label: Label = $ArtSpace/HUD/MartianClock
@onready var data_label: Label = $ArtSpace/HUD/DataCount
@onready var progress: ProgressBar = $ArtSpace/HUD/DataProgress
@onready var alerts: Label = $ArtSpace/HUD/Alerts
@onready var mute_button: Button = $ArtSpace/HUD/MuteButton
var active_panel: Control
var dialog
var current := "OPERATIONS"
var update_timer := 0.0
var report_open := false

func _ready() -> void:
	if not MarsSimulation.initialized:
		MarsSimulation.start_from_pregame()
	$ArtSpace/HUD/LabButton.pressed.connect(show_panel.bind("LAB"))
	$ArtSpace/HUD/EnergyButton.pressed.connect(show_panel.bind("ENERGY"))
	$ArtSpace/HUD/LifeSupportButton.pressed.connect(show_panel.bind("LIFE SUPPORT"))
	$ArtSpace/HUD/OperationsButton.pressed.connect(show_panel.bind("OPERATIONS"))
	$ArtSpace/HUD/PauseButton.pressed.connect(toggle_pause)
	mute_button.pressed.connect(MusicManager.toggle_mute)
	MusicManager.mute_changed.connect(_update_mute_text)
	_update_mute_text(MusicManager.muted)
	resized.connect(layout_art)
	layout_art()
	show_panel(current)
	update_hud()

func _update_mute_text(is_muted: bool) -> void:
	mute_button.text = "UNMUTE" if is_muted else "MUTE"

func layout_art() -> void:
	var ratio: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	art.scale = Vector2.ONE * ratio
	art.position = (size - DESIGN_SIZE * ratio) / 2.0

func show_panel(name: String) -> void:
	if MarsSimulation.paused or MarsSimulation.finished or not PANEL_SCENES.has(name):
		return
	current = name
	if is_instance_valid(active_panel):
		active_panel.queue_free()
	active_panel = PANEL_SCENES[name].instantiate()
	slot.add_child(active_panel)
	active_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	update_hud()

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer < 0.35:
		return
	update_timer = 0.0
	update_hud()
	if MarsSimulation.finished and not report_open:
		show_report()

func update_hud() -> void:
	sol_label.text = str(MarsSimulation.sol_number)
	clock_label.text = MarsSimulation.format_time()
	progress.value = 100.0 * MarsSimulation.processed_gb / MarsSimulation.DATA_GOAL_GB
	data_label.text = "%.1f / %.0f GB" % [MarsSimulation.processed_gb, MarsSimulation.DATA_GOAL_GB]
	alerts.text = "SOL %d / %d     •     %s" % [MarsSimulation.sol_number, MarsSimulation.MISSION_SOLS, MarsSimulation.warning]
	if is_instance_valid(active_panel) and active_panel.has_method("update_display"):
		active_panel.update_display()

func toggle_pause() -> void:
	if MarsSimulation.finished:
		return
	MarsSimulation.paused = not MarsSimulation.paused
	if MarsSimulation.paused:
		show_pause()
	else:
		clear_modal()

func clear_modal() -> void:
	if is_instance_valid(dialog):
		dialog.queue_free()
	dialog = null
	modal_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _make_dialog() -> void:
	clear_modal()
	dialog = MODAL_SCENE.instantiate()
	modal_slot.add_child(dialog)
	dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	dialog.resumed.connect(toggle_pause)
	dialog.requested_end.connect(end_early)
	dialog.requested_menu.connect(_go_to_menu)

func show_pause() -> void:
	_make_dialog()
	dialog.show_pause(MarsSimulation.sol_number, MarsSimulation.MISSION_SOLS, MarsSimulation.processed_gb, MarsSimulation.DATA_GOAL_GB)

func end_early() -> void:
	MarsSimulation._complete("MISSION ENDED EARLY")
	show_report()

func show_report() -> void:
	report_open = true
	_make_dialog()
	dialog.show_game_over(MarsSimulation.last_report, MarsSimulation.DATA_GOAL_GB, MarsSimulation.MISSION_SOLS)

func _go_to_menu() -> void:
	MarsSimulation.paused = true
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
