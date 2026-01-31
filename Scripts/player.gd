extends CharacterBody3D
class_name Player
const SPEED = 20

@onready var hud: Control = $HUD
@onready var interact_area: Area3D = $InteractArea
@onready var ring: MeshInstance3D = $Ring
@onready var buff_area: Area3D = $BuffArea

const METRONOMO = preload("uid://bqkq4o71cbe0h")
var metronomo_ui : Control = null

var drawn : bool = false
var coins = 10
func _ready():
	hud.set_text_label(coins)

func _physics_process(delta: float) -> void:
	pass
			
func _process(delta: float) -> void:

	var input_vec := Input.get_vector("LEFT","RIGHT", "UP", "DOWN")

	if input_vec != Vector2.ZERO:
		var dir := Vector3(input_vec.x, 0, input_vec.y)
		dir = dir.normalized()
		velocity += dir * delta * SPEED
		#velocity.x += clampf(dir.x * delta * SPEED, 0.0, 5000.0)
		#velocity.y += clampf(dir.y * delta * SPEED, 0.0, 0.0)
		#velocity.z += clampf(dir.z * delta * SPEED, 0.0, 5000.0)
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DRAW_INSTRUMENT"):

		if drawn == false:
			metronomo_ui = METRONOMO.instantiate() as Control
			get_tree().current_scene.add_child(metronomo_ui)
			metronomo_ui.buff.connect(_buff_emitter)
			#metro.is_playing = true
			#metro.visible = true
			drawn = true
		else:

			metronomo_ui.queue_free()
			metronomo_ui = null
			#metro.is_playing = false
			#metro.visible = false
			drawn = false
			
	#if Input.is_action_just_pressed("INTERACT"):
	if event.is_action_pressed("INTERACT"):
		
		var overlapping_areas = interact_area.get_overlapping_areas()
		
		#var area_overlapped = overlapping_areas.get(0)
		for area_overlapped in overlapping_areas:
			if area_overlapped is TowerArea:
				if area_overlapped.is_built == false:
					if coins >= 3:
						coins = clamp(coins - 3, 0, 999)
						area_overlapped.build_tower()
						hud.set_text_label(coins)

func _buff_emitter(flag):
	#ring.visible = flag
	if flag == false:
		pass
		#await get_tree().create_timer(1.0).timeout
		#ring.visible = false
	else:
		#ring.visible = true
		for area in buff_area.get_overlapping_areas():
			if area is TowerArea:
				area.get_buff()
