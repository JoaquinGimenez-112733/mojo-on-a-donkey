extends CharacterBody3D
const SPEED = 20

func _process(delta: float) -> void:
	var input_vec := Input.get_vector("LEFT","RIGHT", "UP", "DOWN")

	if input_vec != Vector2.ZERO:
		var dir := Vector3(input_vec.x, 0, input_vec.y)
		dir = dir.normalized()
		velocity += dir * delta * SPEED
		
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0
	move_and_slide()
