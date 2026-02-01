extends Area3D
class_name TowerArea
signal totembuilt
#@onready var statue_2: Node3D = $"../totem"
var RADIAL = preload("uid://yq1epr2xkufo").instantiate()
@onready var totem_container: Node3D = $"../TotemContainer"
var TOTEM_COLISION = preload("uid://0g3jcaiysdra").instantiate()
var TOTEM_COLISION_2 = preload("uid://deomjs4an2wqv").instantiate()
var current_totem : Node3D = null

var is_built = false

func build_tower(idx : int):
	if is_built == false:
		if idx == 0:
			totem_container.add_child(TOTEM_COLISION)
			pass
		elif idx == 1:
			totem_container.add_child(TOTEM_COLISION_2)
			pass
		elif idx == 2:
			pass
		play_build_effect()
		#statue_2.visible = true
		is_built = true
		remove_child(RADIAL)
		
		totembuilt.emit()
		if BusSignal.coins >= 3:
			BusSignal.notify_coin_update(-3)
func play_build_effect():
	for i in totem_container.get_children():
		if i.is_in_group("totem"):
			current_totem = i
			
	current_totem.scale = Vector3.ZERO
	#statue_2.scale = Vector3.ZERO
	
	
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BOUNCE)
	t.tween_property($"../TotemContainer/structure2", "scale", Vector3(0,0,0), 0.65)
	$"campfire-pit2".get_node("Fire").visible = true
	t.tween_property(current_totem, "scale", Vector3(0.6,0.6,0.6), 0.65)
	
func get_buff():
	print("buffed")


func _on_body_entered(body: Node3D) -> void:
	if body is Player and is_built == false:
		add_child(RADIAL)
		if is_instance_valid(RADIAL):
			RADIAL.slice_pressed.connect(_slice_pressed)



func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		remove_child(RADIAL)
	
func _slice_pressed(idx : int):
	if BusSignal.coins >= 3 and is_built == false:
		build_tower(idx)
	else:
		$"../FailSound".play()
