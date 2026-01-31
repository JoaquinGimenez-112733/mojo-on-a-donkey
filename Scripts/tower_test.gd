extends Node3D
@onready var statue_2: Node3D = $statue2
const BULLET = preload("uid://dyof53uxqmruj")
@onready var marker_3d: Marker3D = $Marker3D
@onready var area_attack: Area3D = $statue2/AttackArea

var targets : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_attack.body_entered.connect(_on_area_attack_body_entered)
	area_attack.body_exited.connect(_on_area_attack_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		pass
		#statue_2.visible = true
		#body.set_can_interact(true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		pass
		#body.set_can_interact(false)
		
func get_buff():
	print("buffeada")

func _on_area_attack_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		targets.erase(body)
	#pass
	
func _shoot(target):
	var p = BULLET.instantiate()
	get_tree().current_scene.add_child(p)	
	
	var dir = target.global_position
	
	if p.has_method("setup"):
		p.setup(dir)
	
	
	
	
func _on_area_attack_body_entered(body: Node3D) -> void:
	print(body.name)
	
	if body.is_in_group("enemies"):
		targets.append(body)
