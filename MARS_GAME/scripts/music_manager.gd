extends Node
## Background soundtrack (original synthetic ambience). Replace WAV path to use another track.
signal mute_changed(is_muted: bool)
const MUSIC = preload("res://eee.ogg")
var muted := false
var player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = AudioStreamPlayer.new()
	player.name = "BackgroundMusicPlayer"
	player.bus = "Master"
	player.volume_db = -12.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.stream = MUSIC
	if player.stream is AudioStreamWAV:
		(player.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	player.finished.connect(_restart_if_needed)
	player.play()

func _restart_if_needed() -> void:
	if not muted and not player.playing:
		player.play()

func set_muted(state: bool) -> void:
	muted = state
	if is_instance_valid(player):
		player.volume_db = -80.0 if muted else -12.0
	mute_changed.emit(muted)

func toggle_mute() -> void:
	set_muted(not muted)
