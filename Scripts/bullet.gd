extends CharacterBody3D
var lifetime : float = 5
var damage : int
var speed : float = 20.0

var target : CharacterBody3D

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		velocity = global_position.direction_to(target.global_position) * speed
		look_at(target.global_position)
		
		move_and_slide()
	else:
		queue_free()


func _on_collision_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
