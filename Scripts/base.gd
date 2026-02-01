extends Area3D
signal healtUpdate(h: int)
signal dead 
var healt = 10
const RETRY_SCREEN = preload("uid://bmpgl2yq3ee1h")

func _ready() -> void:
	$Healthbar/VidaRestante.mesh.text = str(healt) + "/10"

func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("enemies"):
		body.queue_free()
		healt = clamp(healt -1, 0, 99)
		
		$Healthbar/VidaRestante.mesh.text = str(healt) + "/10"
		
		healtUpdate.emit(healt)
		if healt == 0:
			var rs = RETRY_SCREEN.instantiate()
			add_child(rs)
			dead.emit()
			
