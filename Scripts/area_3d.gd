extends Area3D
class_name TowerArea
@onready var statue_2: Node3D = $"../statue2"

var is_built = false

func build_tower():
	if is_built == false:
		play_build_effect()
		statue_2.visible = true
		is_built = true
		
func play_build_effect():
	statue_2.scale = Vector3.ZERO
	
	
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BOUNCE)
	
	t.tween_property(statue_2, "scale", Vector3(3,3,3), 0.65)
	
func get_buff():
	print("buffed")
