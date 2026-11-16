extends PanelContainer
## Editable pause / game over dialog; structure is in mission_modal.tscn.
signal resumed
signal requested_end
signal requested_menu
@onready var title_text: Label = $Content/Title
@onready var subtitle: Label = $Content/Subtitle
@onready var stats: RichTextLabel = $Content/Stats
@onready var mute_btn: Button = $Content/MuteButton
@onready var main_btn: Button = $Content/MainButton
@onready var end_btn: Button = $Content/EndButton
@onready var menu_btn: Button = $Content/MenuButton

func _ready() -> void:
    mute_btn.pressed.connect(MusicManager.toggle_mute)
    MusicManager.mute_changed.connect(_update_mute)
    main_btn.pressed.connect(func(): resumed.emit())
    end_btn.pressed.connect(func(): requested_end.emit())
    menu_btn.pressed.connect(func(): requested_menu.emit())
    _update_mute(MusicManager.muted)

func _update_mute(is_muted: bool) -> void:
    mute_btn.text = "UNMUTE MUSIC" if is_muted else "MUTE MUSIC"

func show_pause(sol: int, total: int, processed: float, goal: float) -> void:
    title_text.text = "MISSION PAUSED"
    subtitle.text = "Simulation, crew tasks and rovers are paused."
    stats.text = "[center]SOL %d OF %d     |     DATA %.1f / %.0f GB[/center]\n\nYou can resume, mute the soundtrack, or end the mission early." % [sol,total,processed,goal]
    main_btn.text = "RESUME MISSION"
    main_btn.visible = true
    end_btn.visible = true

func show_game_over(report: Dictionary, goal: float, total: int) -> void:
    var score: int = int(report.get("score", 0))
    var data: float = float(report.get("data", 0.0))
    title_text.text = "MISSION REPORT"
    subtitle.text = "%s  |  SCORE %d / 100" % [str(report.get("reason","MISSION COMPLETE")),score]
    var lines: Array[String] = []
    lines.append("[b]Scientific data:[/b]  %.1f / %.0f GB processed" % [data,goal])
    lines.append("[b]Unprocessed data:[/b]  %.1f GB" % float(report.get("raw",0.0)))
    lines.append("[b]Failures / repairs:[/b]  %d / %d" % [int(report.get("failures",0)),int(report.get("repairs",0))])
    lines.append("[b]Unserved electricity:[/b]  %.1f kWh" % float(report.get("unserved",0.0)))
    lines.append("[b]Oxygen:[/b]  %.1f kg     [b]Water:[/b]  %.1f L     [b]Temperature:[/b]  %.1f °F" % [float(report.get("oxygen",0.0)),float(report.get("water",0.0)),float(report.get("temperature",0.0))])
    lines.append("\n[b]WHAT TO IMPROVE NEXT TIME[/b]")
    if data < goal:
        lines.append("• Send rovers out sooner and schedule more LAB processing.")
    if float(report.get("unserved",0.0)) > 0.0:
        lines.append("• Avoid power shortages by charging batteries and limiting automatic equipment.")
    if int(report.get("failures",0)) > int(report.get("repairs",0)):
        lines.append("• Assign ENERGY / LIFE SUPPORT engineers to damaged devices earlier.")
    if data >= goal and float(report.get("unserved",0.0)) <= 0.0 and int(report.get("failures",0)) <= int(report.get("repairs",0)):
        lines.append("• Excellent balance! Try fewer rovers or fewer optional generators.")
    stats.text = "\n".join(lines)
    main_btn.visible = false
    end_btn.visible = false
