extends Control
# ArcDonutMenu.gd

signal slice_pressed(index: int)

@export var slices := 6

@export var outer_radius := 140.0
@export var inner_radius := 70.0  # agujero del donut

# Arco (por defecto: 180°)
@export var start_angle := -PI
@export var arc_span := PI
@export var arc_points := 28

@export var base_color := Color(0.15, 0.15, 0.18, 0.95)
@export var hover_color := Color(0.35, 0.35, 0.45, 1.0)
@export var border_color := Color(1, 1, 1, 0.14)
@export var border_width := 2.0

# Íconos en cada porción
@export var icons: Array[Texture2D] = []
@export var icon_size := Vector2(48, 48)
@export var icon_tint := Color(1, 1, 1, 1)
@export var hover_icon_bump := 8.0 # cuánto "sale" el ícono hacia afuera al hover

var hovered_index := -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hovered_index = _get_slice_at(event.position)
		queue_redraw()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var idx := _get_slice_at(event.position)
		if idx != -1:
			slice_pressed.emit(idx)

func _draw() -> void:
	var center := size * 0.5
	var slice_ang := arc_span / float(slices)

	for i in slices:
		var a0 := start_angle + slice_ang * i
		var a1 := a0 + slice_ang

		var col := hover_color if i == hovered_index else base_color
		_draw_ring_sector(center, inner_radius, outer_radius, a0, a1, col, arc_points)

		# Bordes (outer + inner)
		draw_arc(center, outer_radius, a0, a1, arc_points, border_color, border_width, true)
		draw_arc(center, inner_radius, a0, a1, arc_points, border_color, border_width, true)

		# Separadores (líneas radiales)
		_draw_separator(center, inner_radius, outer_radius, a0)
		if i == slices - 1:
			_draw_separator(center, inner_radius, outer_radius, a1)

		# Ícono en el centro de la porción
		_draw_icon_for_slice(i, center, a0, a1)

func _draw_ring_sector(center: Vector2, r_in: float, r_out: float, a0: float, a1: float, col: Color, pts: int) -> void:
	var poly := PackedVector2Array()

	# Outer arco
	for j in range(pts + 1):
		var t := float(j) / float(pts)
		var a = lerp(a0, a1, t)
		poly.append(center + Vector2(cos(a), sin(a)) * r_out)

	# Inner arco (vuelta)
	for j in range(pts, -1, -1):
		var t := float(j) / float(pts)
		var a = lerp(a0, a1, t)
		poly.append(center + Vector2(cos(a), sin(a)) * r_in)

	draw_colored_polygon(poly, col)

func _draw_separator(center: Vector2, r_in: float, r_out: float, a: float) -> void:
	var p0 := center + Vector2(cos(a), sin(a)) * r_in
	var p1 := center + Vector2(cos(a), sin(a)) * r_out
	draw_line(p0, p1, border_color, border_width, true)

func _draw_icon_for_slice(i: int, center: Vector2, a0: float, a1: float) -> void:
	if i >= icons.size():
		return
	var tex := icons[i]
	if tex == null:
		return

	var amid := (a0 + a1) * 0.5
	var r_mid := (inner_radius + outer_radius) * 0.5

	var bump := hover_icon_bump if i == hovered_index else 0.0
	var pos := center + Vector2(cos(amid), sin(amid)) * (r_mid + bump)

	var rect := Rect2(pos - icon_size * 0.5, icon_size)
	draw_texture_rect(tex, rect, false, icon_tint)

func _get_slice_at(local_pos: Vector2) -> int:
	var center := size * 0.5
	var v := local_pos - center
	var d := v.length()

	# fuera del donut
	if d < inner_radius or d > outer_radius:
		return -1

	# ángulo del mouse
	var ang := atan2(v.y, v.x) # [-PI, PI]

	# normalizamos dentro del arco [start_angle, start_angle+arc_span)
	var rel := _wrap_angle(ang - start_angle) # [0, TAU)

	# si cae fuera del span, no cuenta
	if rel < 0.0 or rel >= arc_span:
		return -1

	var slice_ang := arc_span / float(slices)
	var idx := int(floor(rel / slice_ang))
	return clampi(idx, 0, slices - 1)

func _wrap_angle(a: float) -> float:
	# devuelve [0, TAU)
	return fposmod(a, TAU)
