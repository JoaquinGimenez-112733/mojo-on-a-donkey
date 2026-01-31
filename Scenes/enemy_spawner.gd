extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval := 5.0
@export var enemies_per_wave := 10
@export var target_position: Vector3

@onready var spawn_point: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

var spawned := 0

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _spawn_enemy():
	if spawned >= enemies_per_wave:
		timer.stop()
		return

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position

	if enemy.has_method("set_target"):
		enemy.set_target(target_position)

	get_tree().current_scene.add_child(enemy)
	spawned += 1
