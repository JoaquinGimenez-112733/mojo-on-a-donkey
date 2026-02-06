extends Node3D

#@export var grid_map: GridMap
@onready var grid_map: GridMap = $GridMap

@export var marker_item_id: int = 2
@export var tree_mesh: Mesh

@export var chunk_size: int = 32
@export var hide_gridmap_after_bake := true

# NUEVO: densidad y randomización
@export var trees_per_tile: int = 10
@export_range(0.0, 1.0, 0.01) var jitter_ratio := 0.45
# jitter_ratio = 0.45 => se mueve hasta el 45% del tamaño de celda hacia cada lado (sin salir del tile)

@export var random_y_rotation := true
@export var min_uniform_scale := 0.4
@export var max_uniform_scale := 0.7
#@export var seed := 12345
@export var seed := -1  # -1 = random

# Opcional: evitar amontonamiento (simple)
@export var use_min_separation := true
@export var min_separation_meters := 0.5
@export var max_tries_per_tree := 12

func _ready() -> void:
	print("new test")
	bake_trees()

func bake_trees() -> void:
	var rng := RandomNumberGenerator.new()
	if seed < 0:
		rng.randomize()
	else:
		rng.seed = seed
	if grid_map == null or tree_mesh == null:
		push_error("Falta asignar grid_map o tree_mesh.")
		return

	#var rng := RandomNumberGenerator.new()
	#rng.seed = seed

	var cs: Vector3 = grid_map.cell_size
	var max_offset_x := cs.x * jitter_ratio
	var max_offset_z := cs.z * jitter_ratio

	# chunk_key (Vector2i) -> Array[Transform3D]
	var by_chunk: Dictionary = {}

	for cell: Vector3i in grid_map.get_used_cells():
		if grid_map.get_cell_item(cell) != marker_item_id:
			continue

		# Transform base (centro del tile, con orientación del cell si la usaste)
		var base_t := _cell_global_transform(cell)

		# Generar N árboles dentro del tile
		var local_points: Array[Vector3] = []  # para min separation (en coords locales del tile)

		for n in trees_per_tile:
			var offset = _random_offset_in_tile(rng, max_offset_x, max_offset_z, local_points)
			if offset == null:
				# no encontró posición válida (si min_separation es muy alto)
				continue

			var t := base_t
			# Aplicar offset en el plano del tile (X/Z en espacio del tile)
			# Ojo: esto respeta la orientación del basis del tile
			t.origin += base_t.basis * offset

			# random rot/scale
			var basis := t.basis
			if random_y_rotation:
				basis = Basis(Vector3.UP, rng.randf_range(0.0, TAU)) * basis

			var s := rng.randf_range(min_uniform_scale, max_uniform_scale)
			basis = basis.scaled(Vector3.ONE * s)

			t.basis = basis

			var ck := Vector2i(floori(float(cell.x) / chunk_size), floori(float(cell.z) / chunk_size))
			if not by_chunk.has(ck):
				by_chunk[ck] = []
			by_chunk[ck].append(t)

	# Crear un MultiMeshInstance3D por chunk
	for ck in by_chunk.keys():
		var transforms: Array = by_chunk[ck]

		var mm := MultiMesh.new()
		mm.mesh = tree_mesh
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.instance_count = transforms.size()

		for i in mm.instance_count:
			mm.set_instance_transform(i, transforms[i])

		# AABB aproximado del chunk (ajustá altura según tu árbol)
		mm.custom_aabb = _chunk_aabb_world(ck)

		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.name = "Trees_%s_%s" % [ck.x, ck.y]
		add_child(mmi)

	if hide_gridmap_after_bake:
		grid_map.visible = true


func _cell_global_transform(cell: Vector3i) -> Transform3D:
	var origin_local := grid_map.map_to_local(cell)
	var ortho := grid_map.get_cell_item_orientation(cell)
	var basis_local := grid_map.get_basis_with_orthogonal_index(ortho)
	var local_t := Transform3D(basis_local, origin_local)
	return grid_map.global_transform * local_t


func _random_offset_in_tile(rng: RandomNumberGenerator, max_x: float, max_z: float, local_points: Array[Vector3]) -> Variant:
	if not use_min_separation:
		return Vector3(rng.randf_range(-max_x, max_x), 0.0, rng.randf_range(-max_z, max_z))

	# Con separación mínima: intentos
	for _i in max_tries_per_tree:
		var candidate := Vector3(rng.randf_range(-max_x, max_x), 0.0, rng.randf_range(-max_z, max_z))
		var ok := true
		for p in local_points:
			if p.distance_to(candidate) < min_separation_meters:
				ok = false
				break
		if ok:
			local_points.append(candidate)
			return candidate

	return null


func _chunk_aabb_world(chunk_key: Vector2i) -> AABB:
	var cs: Vector3 = grid_map.cell_size
	var size_world := Vector3(cs.x * chunk_size, 25.0, cs.z * chunk_size) # 25m alto aprox
	var min_cell := Vector3(chunk_key.x * chunk_size, 0, chunk_key.y * chunk_size)
	var origin_world := grid_map.global_transform * Vector3(min_cell.x * cs.x, 0, min_cell.z * cs.z)
	return AABB(origin_world, size_world)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
