extends Control
## Interactive clickable areas on top of the English art (1672 x 941 px).
## The UI is resolution independent and uses letterboxing to avoid distorted hitboxes.
const MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"
const ART_SIZE := Vector2(1672.0, 941.0)
const ART_OVERVIEW: Texture2D = preload("res://assets/pregame/overview.jpg")
const ART_ENERGY: Texture2D = preload("res://assets/pregame/energy.jpg")
const ART_OPERATIONS: Texture2D = preload("res://assets/pregame/operations.jpg")
const HOVER_COLOR := Color(1.0, 1.0, 1.0, 0.14)

var view: String = "overview"
var art_space: Control
var background: TextureRect
var interactive: Control
var count_displays: Dictionary = {}
var solar_display: Label
var wind_display: Label
var info_panel: PanelContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_space = Control.new()
	art_space.name = "ArtSpace"
	art_space.size = ART_SIZE
	add_child(art_space)
	background = TextureRect.new()
	background.name = "Illustration"
	background.position = Vector2.ZERO
	background.size = ART_SIZE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_space.add_child(background)
	interactive = Control.new()
	interactive.name = "InteractiveControls"
	interactive.size = ART_SIZE
	art_space.add_child(interactive)
	resized.connect(_layout)
	_layout()
	_show_view("overview")

func _layout() -> void:
	if not is_instance_valid(art_space): return
	var window_size: Vector2 = size
	if window_size.x <= 0 or window_size.y <= 0: return
	var scale_factor: float = minf(window_size.x / ART_SIZE.x, window_size.y / ART_SIZE.y)
	art_space.scale = Vector2.ONE * scale_factor
	art_space.position = (window_size - ART_SIZE * scale_factor) * 0.5

func _clear_controls() -> void:
	count_displays.clear()
	solar_display = null
	wind_display = null
	for child in interactive.get_children():
		interactive.remove_child(child)
		child.queue_free()

func _show_view(next_view: String) -> void:
	view = next_view
	_clear_controls()
	match view:
		"overview":
			background.texture = ART_OVERVIEW
			_click_area("Energy", Rect2(240, 395, 600, 372), func(): _show_view("energy"))
			_click_area("Operations", Rect2(860, 395, 625, 372), func(): _show_view("operations"))
			_click_area("Back", Rect2(705, 822, 260, 110), func(): get_tree().change_scene_to_file(MENU_SCENE))
			_click_area("Continue", Rect2(1045, 822, 445, 110), _show_review)
		"energy":
			background.texture = ART_ENERGY
			_click_area("PhotovoltaicToggle", Rect2(430, 725, 285, 74), func(): _toggle_optional("photovoltaic"))
			_click_area("WindToggle", Rect2(1095, 725, 290, 74), func(): _toggle_optional("wind_energy"))
			# Painted number/word overlays display live selection state.
			solar_display = _state_pill(Rect2(450, 732, 248, 57))
			wind_display = _state_pill(Rect2(1111, 732, 258, 57))
			_click_area("Back", Rect2(704, 822, 248, 107), func(): _show_view("overview"))
			_click_area("Continue", Rect2(1017, 822, 411, 107), func(): _show_view("overview"))
			_refresh_energy()
		"operations":
			background.texture = ART_OPERATIONS
			_counter("humans", Rect2(1174, 392, 149, 111))
			_counter("rovers", Rect2(1174, 631, 149, 111))
			_click_area("HumansMinus", Rect2(1063, 392, 115, 112), func(): _adjust("humans", -1))
			_click_area("HumansPlus", Rect2(1326, 392, 117, 112), func(): _adjust("humans", 1))
			_click_area("RoversMinus", Rect2(1063, 631, 115, 112), func(): _adjust("rovers", -1))
			_click_area("RoversPlus", Rect2(1326, 631, 117, 112), func(): _adjust("rovers", 1))
			_click_area("Back", Rect2(704, 821, 248, 108), func(): _show_view("overview"))
			_click_area("Continue", Rect2(1040, 821, 438, 108), func(): _show_view("overview"))
			_refresh_counters()

func _click_area(key: String, bounds: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.name = key
	button.tooltip_text = key
	button.position = bounds.position
	button.size = bounds.size
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var hover := StyleBoxFlat.new()
	hover.bg_color = HOVER_COLOR
	hover.set_corner_radius_all(22)
	button.add_theme_stylebox_override("hover", hover)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(1.0, 1.0, 1.0, 0.25)
	pressed.set_corner_radius_all(22)
	button.add_theme_stylebox_override("pressed", pressed)
	interactive.add_child(button)
	button.pressed.connect(callback)
	return button

func _state_pill(bounds: Rect2) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0.1,0.19,0.05,0.85))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interactive.add_child(label)
	return label

func _toggle_optional(module_id: String) -> void:
	if module_id == "photovoltaic":
		GameSetup.set_optional(module_id, not GameSetup.photovoltaic)
	elif module_id == "wind_energy":
		GameSetup.set_optional(module_id, not GameSetup.wind_energy)
	_refresh_energy()

func _refresh_energy() -> void:
	if not is_instance_valid(solar_display) or not is_instance_valid(wind_display): return
	for obj in [solar_display, wind_display]:
		var style := StyleBoxFlat.new()
		var active: bool = GameSetup.photovoltaic if obj == solar_display else GameSetup.wind_energy
		style.bg_color = Color("237d24") if active else Color("218d22")
		style.border_color = Color("d2ff9a")
		style.set_border_width_all(2)
		style.set_corner_radius_all(26)
		obj.add_theme_stylebox_override("normal", style)
		obj.text = "✓ SELECTED" if active else "+ SELECT"

func _counter(kind: String, bounds: Rect2) -> void:
	var display := Label.new()
	display.name = kind.capitalize() + "Count"
	display.position = bounds.position
	display.size = bounds.size
	display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	display.add_theme_font_size_override("font_size", 62)
	display.add_theme_color_override("font_color", Color("611624"))
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("fff0c6")
	fill.border_color = Color("aa551f")
	fill.set_border_width_all(3)
	fill.set_corner_radius_all(20)
	display.add_theme_stylebox_override("normal", fill)
	interactive.add_child(display)
	count_displays[kind] = display

func _adjust(kind: String, delta: int) -> void:
	GameSetup.set_count(kind, (GameSetup.humans if kind == "humans" else GameSetup.rovers) + delta)
	_refresh_counters()

func _refresh_counters() -> void:
	for kind in count_displays:
		var display: Label = count_displays[kind]
		if is_instance_valid(display):
			display.text = str(GameSetup.humans if kind == "humans" else GameSetup.rovers)

func _show_review() -> void:
	if is_instance_valid(info_panel): return
	var problem: String = GameSetup.validate_selection()
	info_panel = PanelContainer.new()
	info_panel.name = "ReviewOverlay"
	info_panel.position = Vector2(474, 220)
	info_panel.size = Vector2(730, 490)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("172748")
	panel_style.border_color = Color("ffbe4b")
	panel_style.set_border_width_all(9)
	panel_style.set_corner_radius_all(28)
	panel_style.content_margin_left = 38.0
	panel_style.content_margin_right = 38.0
	panel_style.content_margin_top = 24.0
	panel_style.content_margin_bottom = 24.0
	info_panel.add_theme_stylebox_override("panel", panel_style)
	interactive.add_child(info_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	info_panel.add_child(column)
	var title := Label.new()
	title.text = "MISSION SETUP REVIEW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("ffe28c"))
	column.add_child(title)
	var summary := Label.new()
	summary.text = problem if problem != "" else GameSetup.get_summary()
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 25)
	summary.add_theme_color_override("font_color", Color.WHITE)
	summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(summary)
	var note := Label.new()
	note.text = "Your choices will configure the 30-sol scientific mission."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 17)
	column.add_child(note)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	var close_button := _review_button("EDIT SETUP", Color("168ec6"))
	row.add_child(close_button)
	close_button.pressed.connect(_close_review)
	var confirm_button := _review_button("CONFIRM SETUP", Color("3a9d29"))
	confirm_button.disabled = problem != ""
	row.add_child(confirm_button)
	confirm_button.pressed.connect(_confirm_setup.bind(summary, note, confirm_button))

func _review_button(label_text: String, color: Color) -> Button:
	var b := Button.new()
	b.text = label_text
	b.custom_minimum_size = Vector2(0, 64)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 24)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	b.add_theme_stylebox_override("normal", style)
	return b

func _confirm_setup(summary: Label, note: Label, confirm_button: Button) -> void:
	if GameSetup.prepared:
		_start_game()
		return
	GameSetup.prepared = true
	summary.text = "SETUP CONFIRMED!\n\n" + GameSetup.get_summary()
	note.text = "Your mission is ready. Start the base to manage your crew and rovers."
	confirm_button.disabled = false
	confirm_button.text = "START GAME"


func _close_review() -> void:
	if is_instance_valid(info_panel):
		info_panel.queue_free()
	info_panel = null

func _start_game() -> void:
	MarsSimulation.start_from_pregame()
	get_tree().change_scene_to_file("res://scenes/game/Marcian_base.tscn")
