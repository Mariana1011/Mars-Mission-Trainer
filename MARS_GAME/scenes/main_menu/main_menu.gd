extends Control
## Glossy English menu art, with clickable Godot controls placed on top.
const ART_SIZE := Vector2(1672.0, 941.0)
const PREGAME_SCENE := "res://scenes/pregame/pregame.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings.tscn"
const MENU_ART: Texture2D = preload("res://assets/pregame/main.jpg")
var art_space: Control

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art_space = Control.new()
    art_space.size = ART_SIZE
    add_child(art_space)
    var bg := TextureRect.new()
    bg.texture = MENU_ART
    bg.size = ART_SIZE
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_SCALE
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    art_space.add_child(bg)
    _button("NewGame", Rect2(450, 327, 785, 179), _on_new_game_pressed)
    _button("Options", Rect2(463, 515, 752, 162), _on_options_pressed)
    _button("Quit", Rect2(473, 692, 704, 161), _on_quit_pressed)
    resized.connect(_layout)
    _layout()

func _layout() -> void:
    if not is_instance_valid(art_space): return
    var ratio: float = minf(size.x / ART_SIZE.x, size.y / ART_SIZE.y)
    art_space.scale = Vector2.ONE * ratio
    art_space.position = (size - ART_SIZE * ratio) * 0.5

func _button(name_value: String, rect: Rect2, action: Callable) -> void:
    var button := Button.new()
    button.name = name_value
    button.position = rect.position
    button.size = rect.size
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    var hover := StyleBoxFlat.new()
    hover.bg_color = Color(1, 1, 1, 0.16)
    hover.set_corner_radius_all(60)
    button.add_theme_stylebox_override("hover", hover)
    art_space.add_child(button)
    button.pressed.connect(action)

func _on_new_game_pressed() -> void:
    GameSetup.reset_selection()
    get_tree().change_scene_to_file(PREGAME_SCENE)

func _on_options_pressed() -> void:
    get_tree().change_scene_to_file(SETTINGS_SCENE)

func _on_quit_pressed() -> void:
    get_tree().quit()
