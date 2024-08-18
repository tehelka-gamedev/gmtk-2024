extends Node

signal BGM_mute_state_changed(is_muted:bool)
signal SE_mute_state_changed(is_muted:bool)

const BGM_BUS:String = "BGM"
const SE_BUS:String = "SE"

var _fading:bool = false
var _tween:Tween = null
var BGM_bus_index = AudioServer.get_bus_index(BGM_BUS)
var SE_bus_index = AudioServer.get_bus_index(SE_BUS)

@onready var _music_player : AudioStreamPlayer = $MusicPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_music_player.bus = BGM_BUS
	await get_tree().create_timer(0.1).timeout


func PlayMusic(stream:AudioStream, fade_in_time:float=0.25) -> void:
	# If the same music is already playing, don't do anything
	if _music_player.stream == stream:
		return

	if _music_player.playing and not _fading:
		await FadeOutMusic(0.5)
	elif _music_player.playing and _fading:
		_tween.kill()
		_fading = false
	_music_player.stream = stream
	_music_player.volume_db = AudioServer.get_bus_volume_db(BGM_bus_index) - 100
	_music_player.play()
	_tween = get_tree().create_tween()
	_fading = true
	_tween.tween_property(_music_player, "volume_db", AudioServer.get_bus_volume_db(BGM_bus_index), fade_in_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await _tween.finished
	_fading = false


func PlaySoundEffect(stream:AudioStream) -> void:
	var sound_player:AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.stream = stream
	sound_player.bus = SE_BUS
	sound_player.finished.connect(sound_player.queue_free)
	add_child(sound_player)
	sound_player.play()


func MusicIsPlaying() -> bool:
	return _music_player.playing

func StopMusic() -> void:
	_music_player.stop()

func FadeOutMusic(duration:float = 1.5) -> void:
	_tween = get_tree().create_tween()
	_fading = true
	_tween.tween_property(_music_player, "volume_db", -100, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	await _tween.finished
	_music_player.stop()
	_fading = false

# Set BGM bus volume
# volume: 0-100
func SetBGMVolume(volume:float) -> void:
	AudioServer.set_bus_volume_db(BGM_bus_index, linear_to_db(volume/100))

# Set SE bus volume
# volume: 0-100
func SetSEVolume(volume:float) -> void:
	AudioServer.set_bus_volume_db(SE_bus_index, linear_to_db(volume/100))

func MuteBGM(is_muted:bool)	-> void:
	var was_muted:bool = AudioServer.is_bus_mute(BGM_bus_index)

	AudioServer.set_bus_mute(BGM_bus_index, is_muted)
	if was_muted != is_muted:
		BGM_mute_state_changed.emit(is_muted)

func MuteSE(is_muted:bool)	-> void:
	var was_muted:bool = AudioServer.is_bus_mute(SE_bus_index)

	AudioServer.set_bus_mute(SE_bus_index, is_muted)
	if was_muted != is_muted:
		SE_mute_state_changed.emit(is_muted)

func IsBGMMuted() -> bool:
	return AudioServer.is_bus_mute(BGM_bus_index)

func IsSEMuted() -> bool:
	return AudioServer.is_bus_mute(SE_bus_index)
