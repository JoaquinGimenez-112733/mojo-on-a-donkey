extends Node3D
#@onready var statue_2: Node3D = $totem
const BULLET = preload("uid://dyof53uxqmruj")
var RADIAL = preload("uid://yq1epr2xkufo").instantiate()
var totem_built = false
const bullet_damage = 50
var curr : CharacterBody3D
var can_shoot : bool = true
@onready var marker_3d: Marker3D = $TotemContainer/Aim
@onready var area_attack: Area3D = $TotemContainer/AttackArea
var current_totem : Node3D

var targets : Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_attack.body_entered.connect(_on_area_attack_body_entered)
	area_attack.body_exited.connect(_on_area_attack_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if totem_built == true:
		if is_instance_valid(curr):
			if current_totem == null:
				for t in $TotemContainer.get_children():
					if t.is_in_group("totem"):
						current_totem = t
			else:
				current_totem.look_at(curr.global_position)
				
			#$TotemContainer.look_at(curr.global_position)
			if can_shoot:			
				_shoot()
				can_shoot = false
				$ShootingCD.start()
		else:
			for i in get_node("BulletContainer").get_child_count():
				get_node("BulletContainer").get_child(i).queue_free()


	
func _on_area_attack_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		targets.erase(body)
	#pass

	
func _shoot():
	var p : CharacterBody3D = BULLET.instantiate()
	p.target = curr
	p.damage = bullet_damage
	get_node("BulletContainer").add_child(p)
	p.global_position = $TotemContainer/Aim.global_position
	
	
func _on_area_attack_body_entered(body: Node3D) -> void:
		
	if body.is_in_group("enemies"):
		targets.append(body)
			


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		targets.append(body)
		choose_target(targets)
		

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		targets.erase(body)
		choose_target(targets)
		
func choose_target(_curr_targets : Array):
	var temp_array : Array = _curr_targets
	var current_target : CharacterBody3D = null
	for i in temp_array:
		if current_target == null:
			current_target = i
		else:
			if i.global_position.direction_to(Vector3(0,0,0)) > current_target.global_position.direction_to(Vector3(0,0,0)):
				current_target = i
		
		curr = current_target


func _on_shooting_cd_timeout() -> void:
	can_shoot = true


func _on_area_3d_totembuilt() -> void:
	totem_built = true
