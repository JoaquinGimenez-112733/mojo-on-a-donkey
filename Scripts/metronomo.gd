extends Control
@onready var marcador: TextureRect = $Marcador
@onready var barra: ColorRect = $Barra
@onready var song: AudioStreamPlayer2D = $Song

@export var bpm: float = 70.0
@export var offset: float = 0.0 # ajustás a ojo (puede ser positivo o negativo)

# Zona de acierto en "phase" 0..1 (por ejemplo, una franja centrada)
@export var hit_start: float = 0.65
@export var hit_end: float = 0.95
var beat_len: float

var is_playing : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beat_len = 60.0 / bpm
	song.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_playing:
		var t := get_song_time() + offset
		var phase := fmod(t, beat_len) / beat_len

	# mover marcador por la barra
		var x = lerp(0.0, barra.size.x, phase)
		marcador.position.x = barra.position.x + x
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("RHYTMN_HIT"):
		var t := get_song_time() + offset
		var phase := fmod(t, beat_len) / beat_len

		if is_phase_in_window(phase, hit_start, hit_end):
			print("HIT")  # acá disparás lo que quieras luego
		else:
			print("MISS")
			
func get_song_time() -> float:
		# “más estable” que solo playback_position
		var t := song.get_playback_position()
		t += AudioServer.get_time_since_last_mix()
		t -= AudioServer.get_output_latency()
		return t

func is_phase_in_window(phase: float, a: float, b: float) -> bool:
	# soporta ventanas que cruzan el 0 (ej a=0.9, b=0.1)
	if a <= b:
		return phase >= a and phase <= b
	return phase >= a or phase <= b
