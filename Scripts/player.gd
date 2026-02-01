extends CharacterBody3D
class_name Player
const SPEED = 20
@export var turn_speed := 2.0
@onready var spring_arm_3d: SpringArm3D = $CameraPivot/SpringArm3D
const RADIAL = preload("uid://yq1epr2xkufo")
var menu := preload("uid://yq1epr2xkufo").instantiate()
@onready var hud: Control = $HUD
@onready var interact_area: Area3D = $InteractArea
@onready var ring: MeshInstance3D = $Ring
@onready var buff_area: Area3D = $BuffArea
@onready var chaman: Node3D = $Chamán
var animP : AnimationPlayer
var t : Tween

const METRONOMO = preload("uid://bqkq4o71cbe0h")
var metronomo_ui : Control = null
var inerciando = false

var drawn : bool = false
var coins = 10

const COIN_ADD = preload("uid://iowds4v2r33t")

@export var head_offset := Vector3(0, 1.8, 0) # si no tenés Marker3D

@onready var cam := get_viewport().get_camera_3d()
func _ready():
	BusSignal.notify_coin_update(coins)
	BusSignal.updateCoins.connect(_add_coins)
	spring_arm_3d.collision_mask = 0
	hud.set_text_label(coins)
	animP = chaman.get_node("AnimationPlayer")

func _add_coins():
	
	coins = BusSignal.coins
	hud.set_text_label(coins)
func _physics_process(delta: float) -> void:

	var input_vec := Input.get_vector("LEFT","RIGHT", "UP", "DOWN")
	var target_vel := Vector3.ZERO

	if input_vec != Vector2.ZERO:
		animP.play("Caminata_Burro")
		t.kill()
		inerciando = false
		var dir := Vector3(input_vec.x, 0, input_vec.y).normalized()
		var target_yaw := atan2(dir.x, dir.z)  # si tu modelo mira +Z
		chaman.rotation.y = lerp_angle(chaman.rotation.y, target_yaw, turn_speed * delta)
		target_vel = dir * SPEED
		velocity.x = move_toward(velocity.x, target_vel.x, SPEED  * delta)
		velocity.z = move_toward(velocity.z, target_vel.z, SPEED  * delta)
	else: 
		if inerciando == false:
			inerciando = true
			t = get_tree().create_tween()
			t.set_ease(Tween.EASE_OUT)
			t.tween_property(self, "velocity", Vector3.ZERO, 0.55 )

	
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 1
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DRAW_INSTRUMENT"):

		if drawn == false:
			metronomo_ui = METRONOMO.instantiate() as Control
			get_tree().current_scene.add_child(metronomo_ui)
			metronomo_ui.buff.connect(_buff_emitter)

			drawn = true
		else:

			metronomo_ui.queue_free()
			metronomo_ui = null

			drawn = false

	if event.is_action_pressed("INTERACT"):
		
		var overlapping_areas = interact_area.get_overlapping_areas()

		for area_overlapped in overlapping_areas:
			if area_overlapped is TowerArea:
				if area_overlapped.is_built == false:
					if coins >= 3:
						pass						#coins = clamp(coins - 3, 0, 999)
						#area_overlapped.build_tower()
						#hud.set_text_label(coins)

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


func _on_base_healt_update(h: int) -> void:
	hud.set_healt_label(h)
