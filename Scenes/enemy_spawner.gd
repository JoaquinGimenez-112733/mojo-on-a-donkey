extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval := randi_range(4, 7)
@export var enemies_per_wave := 10
@export var target_position: Vector3

@onready var spawn_point: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

const ENEMY_BAD_02 = preload("uid://ca6mv582j3hgh")
const ENEMY_BAD_03 = preload("uid://bmmjmo4mmr3gq")

var spawned := 0

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _spawn_enemy():
	if spawned >= enemies_per_wave:
		timer.stop()
		return
	var ranf = randf_range(0,1)
	var packed : PackedScene
	if ranf <= 0.33:
		packed = ENEMY_BAD_02
	elif ranf > 0.33 and ranf <= 0.66:
		packed = ENEMY_BAD_03
	else:
		packed = ENEMY_BAD_02
	#var enemy = enemy_scene.instantiate()
	var enemy = packed.instantiate()
	enemy.global_position = spawn_point.global_position

	if enemy.has_method("set_target"):
		enemy.set_target(target_position)
	
	get_tree().current_scene.add_child(enemy)
	spawned += 1


func _on_base_dead() -> void:
	timer.stop()
