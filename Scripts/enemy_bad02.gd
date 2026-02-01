extends CharacterBody3D
class_name Enemy02

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var target_pos: Vector3
var has_target: bool = false
var healt : float = 20
@onready var animP : AnimationPlayer

@export var SPEED: float = 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animP = $Bad03.get_node("AnimationPlayer")
	target_pos = Vector3(0, 0, 0)
	has_target = true
	velocity = Vector3.ZERO
	await get_tree().physics_frame
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if has_target:
		animP.play("Huesos_Bad2Action")
		nav_agent.target_position = target_pos
		var next_path_pos := nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		velocity = direction.normalized() * SPEED
		
		if nav_agent.is_navigation_finished():
			
			velocity = Vector3.ZERO
			#queue_free()
			
		## ROTACION EN MOVIMIENTO
		var ROTATION_SPEED = 4
		var target_angle := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10)
		#var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
		#if abs(target_rotation - rotation.y) > deg_to_rad(60):
			#ROTATION_SPEED = 20
		#rotation.y = move_toward(rotation.y, target_rotation, delta * ROTATION_SPEED)
		
	move_and_slide()
		
		
func take_damage(dmg : float):
	healt -= dmg
	
	if healt <= 0:
		var rand_coins = randi_range(0, 2)
		BusSignal.notify_coin_update(rand_coins)
		queue_free()
