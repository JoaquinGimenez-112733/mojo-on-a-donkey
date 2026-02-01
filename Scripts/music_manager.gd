extends Node

@export var fade_time := 1.2
@export var silence_db := -80.0
@export var target_db := -15.0

@onready var a: AudioStreamPlayer = $MusicaMainMenu
@onready var b: AudioStreamPlayer = $MusicaCoreGameplay

var _active: AudioStreamPlayer
var _inactive: AudioStreamPlayer
var _tween: Tween

func _ready() -> void:
	_active = a
	_inactive = b
	_active.volume_db = target_db
	_inactive.volume_db = silence_db

func play_music(stream: AudioStream, fade := true, from_pos := 0.0, loop := true) -> void:
	if stream == null:
		return

	# Si ya suena este mismo stream en el activo, no hagas nada
	if _active.playing and _active.stream == stream:
		return

	_inactive.stream = stream
	_inactive.volume_db = silence_db
	_inactive.play(from_pos)

	# (Opcional) forzar loop en runtime
	if _inactive.stream:
		_inactive.stream.loop = loop  # funciona en streams que soportan loop

	# Cortar tween anterior si existía
	if _tween and _tween.is_running():
		_tween.kill()

	if not fade or fade_time <= 0.0:
		_active.stop()
		_inactive.volume_db = target_db
		_swap_players()
		return

	_tween = create_tween()
	_tween.set_parallel(true)

	_tween.tween_property(_active, "volume_db", silence_db, fade_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_tween.tween_property(_inactive, "volume_db", target_db, fade_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_tween.finished.connect(func():
		_active.stop()
		_swap_players()
	)

func stop_music(fade := true) -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	if not fade:
		_active.stop()
		_inactive.stop()
		return

	_tween = create_tween()
	_tween.tween_property(_active, "volume_db", silence_db, fade_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.finished.connect(func():
		_active.stop()
	)

func _swap_players() -> void:
	var tmp := _active
	_active = _inactive
	_inactive = tmp
