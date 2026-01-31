extends Node3D
@onready var statue_2: Node3D = $statue2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
