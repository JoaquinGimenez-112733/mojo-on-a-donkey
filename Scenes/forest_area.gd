@tool
extends Node3D

@export var tree_count := 120
@export var area_padding := 0.5

@onready var obstacle := $NavigationObstacle3D
@onready var trees := $MultiMeshInstance3D

func _ready():
	#generate_trees()
	pass

func generate_trees():
	if obstacle.vertices.size() < 3:
		return

	var verts: PackedVector3Array = obstacle.vertices
	var poly: Array[Vector2] = []

	# Pasar a 2D (local X/Z)
	for v in verts:
		poly.append(Vector2(v.x, v.z))

	# Bounding box
	var min_v := poly[0]
	var max_v := poly[0]
	for p in poly:
		min_v.x = min(min_v.x, p.x)
		min_v.y = min(min_v.y, p.y)
		max_v.x = max(max_v.x, p.x)
		max_v.y = max(max_v.y, p.y)

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = tree_count

	var space := get_world_3d().direct_space_state

	var i := 0
	while i < tree_count:
		var x := randf_range(min_v.x + area_padding, max_v.x - area_padding)
		var z := randf_range(min_v.y + area_padding, max_v.y - area_padding)

		var p2 := Vector2(x, z)
		if not Geometry2D.is_point_in_polygon(p2, poly):
			continue

		var local_pos := Vector3(x, 0, z)
		var world_pos: Vector3 = obstacle.global_transform * local_pos

		# Raycast al suelo (Godot 4)
		var from := world_pos + Vector3.UP * 10.0
		var to := world_pos + Vector3.DOWN * 30.0

		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var hit := space.intersect_ray(query)
		if hit:
			world_pos.y = hit["position"].y

		var t := Transform3D()
		t.origin = world_pos
		t.basis = Basis().scaled(Vector3.ONE * randf_range(0.8, 1.3))

		mm.set_instance_transform(i, t)
		i += 1

	trees.multimesh = mm
