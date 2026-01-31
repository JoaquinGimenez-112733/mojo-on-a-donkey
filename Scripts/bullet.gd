extends Area3D
var lifetime : float = 5
var damage : float = 20.0
var speed : float = 25.0

var velocity = Vector3.ZERO

func _ready():	
	body_entered.connect(_on_body_entered)	
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
func _on_body_entered(body : Node):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	
func setup(dir: Vector3):
	velocity = dir.normalized() * speed
	
func _physics_process(delta: float) -> void:
	global_position += velocity * delta
