extends Control
@export var float_px := 60.0
@export var duration := 0.8
@onready var label: Label = $Label

func play(amount: int) -> void:
	label.text = "+%d" % amount

	# Estado inicial
	var start_pos := position
	modulate.a = 1.0

	# Tween: subir + desvanecer + (opcional) escalar un toque
	var tw := create_tween()
	tw.set_parallel(true)

	tw.tween_property(label, "position:y", start_pos.y - float_px, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tw.tween_property(label, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# pequeño “pop”
	label.scale = Vector2.ONE * 0.9
	tw.tween_property(label, "scale", Vector2.ONE, duration * 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tw.finished.connect(queue_free)
