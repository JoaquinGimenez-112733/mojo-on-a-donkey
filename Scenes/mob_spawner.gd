extends Path3D
@onready var path_follow_3d: PathFollow3D = $PathFollow3D


func _process(delta: float) -> void:
	path_follow_3d.progress += delta * 20
