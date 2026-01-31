extends CharacterBody3D
class_name Player
const SPEED = 20
var can_interact : bool = false
@onready var hud: Control = $HUD
@onready var interact_area: Area3D = $InteractArea

var coins = 10
func _ready():
	hud.set_text_label(coins)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("INTERACT"):
		var overlapping_areas = interact_area.get_overlapping_areas()
		var area_overlapped = overlapping_areas.get(0)
		if area_overlapped is TowerArea:
			if area_overlapped.is_built == false:
				coins = clamp(coins - 3, 0, 999)
				area_overlapped.build_tower()
				hud.set_text_label(coins)
			
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
	
func set_can_interact(flag):
	can_interact = flag
