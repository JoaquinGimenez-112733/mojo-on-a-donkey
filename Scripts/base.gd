extends Area3D
signal healtUpdate(h: int)
var healt = 10
const RETRY_SCREEN = preload("uid://bmpgl2yq3ee1h")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		healt -= 10
		print(healt)
		healtUpdate.emit(healt)
		if healt == 0:
			var rs = RETRY_SCREEN.instantiate()
			add_child(rs)
