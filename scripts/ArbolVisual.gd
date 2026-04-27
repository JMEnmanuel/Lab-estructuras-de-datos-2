extends Node2D

# ─── CONFIGURACIÓN VISUAL ────────────────────────────────────────
const DIAMETRO     := 100.0
const RADIO        := DIAMETRO / 2.0
const COLOR_NODO   := Color(0.10, 0.22, 0.40)
const COLOR_BORDE  := Color(0.25, 0.72, 0.90)
const COLOR_TEXTO  := Color(1.0, 1.0, 1.0)
const COLOR_GRAV   := Color(0.55, 0.95, 1.0)
const COLOR_TIPO   := Color(0.78, 0.88, 1.0)
const COLOR_LINEA  := Color(0.55, 0.55, 0.65, 0.90)
const COLOR_NUEVO  := Color(0.12, 0.72, 0.38)
const COLOR_BORDE_NUEVO := Color(0.40, 1.0, 0.60)
const GROSOR_LINEA := 2.5
const GROSOR_BORDE := 3.0

# Fondo del panel
const COLOR_FONDO_PANEL  := Color(0.05, 0.08, 0.15, 0.75)
const COLOR_BORDE_PANEL  := Color(0.20, 0.40, 0.65, 0.60)
const GROSOR_BORDE_PANEL := 2.0

const MARGEN_TOP  := 80.0
const MARGEN_BOT  := 80.0
const MARGEN_IZQ  := 60.0
const MARGEN_DER  := 60.0

# ─── ANIMACIÓN ───────────────────────────────────────────────────
const DURACION_LINEA  := 0.80
const DURACION_NODO   := 0.45
const DELAY_NODO      := 0.20
const PULSO_ESCALA    := 1.08   # Cuánto crece el nodo en el pulso
const PULSO_DURACION  := 0.70   # Duración de medio ciclo del pulso

# ─── TOOLTIP ─────────────────────────────────────────────────────
const COLOR_TOOLTIP_BG   := Color(0.05, 0.10, 0.20, 0.92)
const COLOR_TOOLTIP_BORD := Color(0.25, 0.72, 0.90, 0.80)
const COLOR_TOOLTIP_TEXT := Color(0.90, 0.95, 1.0)

# ─── ESTADO INTERNO ──────────────────────────────────────────────
var _ultimo_id: int    = -1
var _total_nodos: int  = 0
var _draw_data: Array  = []
var _lineas_anim: Array = []

var _panel_fondo: Panel = null   # Fondo semitransparente
var _tooltip: Panel     = null   # Tooltip flotante
var _nodo_pulsando      = null   # Panel del nodo verde que pulsa
var _tween_pulso: Tween = null


# ─── API PÚBLICA ─────────────────────────────────────────────────

func redibujar(raiz_arbol, ultimo_id: int = -1):
	_ultimo_id = ultimo_id
	_draw_data.clear()
	_lineas_anim.clear()
	_nodo_pulsando = null

	# Detener pulso anterior
	if _tween_pulso != null and _tween_pulso.is_valid():
		_tween_pulso.kill()

	for hijo in get_children():
		hijo.queue_free()
	_panel_fondo = null
	_tooltip = null

	if raiz_arbol == null:
		queue_redraw()
		return

	_total_nodos = _contar_nodos(raiz_arbol)
	var posiciones = {}
	var indice = [0]
	var altura_arbol = _altura(raiz_arbol)
	_asignar_posicion(raiz_arbol, posiciones, indice, 0, altura_arbol)
	_recolectar_lineas(raiz_arbol, posiciones)
	_recolectar_nodos(raiz_arbol, posiciones)

	_crear_fondo()
	_crear_tooltip()
	_animar()


# ─── FONDO SEMITRANSPARENTE (feature 6) ──────────────────────────

func _crear_fondo():
	var vp = get_viewport_rect().size
	_panel_fondo = Panel.new()
	_panel_fondo.position = Vector2(vp.x / 2.0, 0)
	_panel_fondo.size     = Vector2(vp.x / 2.0, vp.y)
	_panel_fondo.z_index  = -1   # Detrás de todo

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_FONDO_PANEL
	style.border_color = COLOR_BORDE_PANEL
	style.border_width_left = int(GROSOR_BORDE_PANEL)
	style.set_corner_radius_all(0)
	_panel_fondo.add_theme_stylebox_override("panel", style)

	# Fade in del fondo
	_panel_fondo.modulate.a = 0.0
	add_child(_panel_fondo)
	var tw = create_tween()
	tw.tween_property(_panel_fondo, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_LINEAR)


# ─── TOOLTIP (feature 4) ─────────────────────────────────────────

func _crear_tooltip():
	_tooltip = Panel.new()
	_tooltip.visible = false
	_tooltip.z_index = 10   # Encima de todo
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_TOOLTIP_BG
	style.border_color = COLOR_TOOLTIP_BORD
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.anti_aliasing = true
	_tooltip.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.position = Vector2(10, 8)
	_tooltip.add_child(vbox)

	# Labels del tooltip (se rellenan en _mostrar_tooltip)
	for nombre in ["LblTitulo", "LblLey", "LblPena"]:
		var lbl = Label.new()
		lbl.name = nombre
		lbl.add_theme_color_override("font_color", COLOR_TOOLTIP_TEXT)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(lbl)

	add_child(_tooltip)


func _mostrar_tooltip(datos: Dictionary, pos_nodo: Vector2):
	if _tooltip == null:
		return
	var vbox = _tooltip.get_node("VBox")
	vbox.get_node("LblTitulo").text = "📋 %s" % datos["tipo_acoso"]
	vbox.get_node("LblLey").text    = "⚖️ %s" % datos["ley"]
	vbox.get_node("LblPena").text   = "🔒 %s" % datos["pena"]

	# Ajustar tamaño del tooltip al contenido
	var ancho = 260.0
	vbox.size = Vector2(ancho - 20, 0)
	_tooltip.size = Vector2(ancho, 90)

	# Posicionar: intenta a la derecha del nodo, ajusta si se sale
	var vp    = get_viewport_rect().size
	var tx    = pos_nodo.x + RADIO + 10
	var ty    = pos_nodo.y - 45
	if tx + ancho > vp.x:
		tx = pos_nodo.x - RADIO - ancho - 10
	ty = clamp(ty, 5, vp.y - 95)
	_tooltip.position = Vector2(tx, ty)

	_tooltip.modulate.a = 0.0
	_tooltip.visible    = true
	var tw = create_tween()
	tw.tween_property(_tooltip, "modulate:a", 1.0, 0.18)


func _ocultar_tooltip():
	if _tooltip == null or not _tooltip.visible:
		return
	var tw = create_tween()
	tw.tween_property(_tooltip, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func(): if _tooltip != null: _tooltip.visible = false)


# ─── ANIMACIÓN PRINCIPAL ─────────────────────────────────────────

func _animar():
	var delay_acum := 0.0
	for i in _lineas_anim.size():
		var tw = create_tween()
		tw.tween_interval(delay_acum)
		tw.tween_method(
			func(v): _lineas_anim[i]["progreso"] = v; queue_redraw(),
			0.0, 1.0, DURACION_LINEA
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		delay_acum += 0.05

	var delay_nodos = delay_acum + DURACION_LINEA + DELAY_NODO
	_crear_nodos_visuales(delay_nodos)


# ─── DIBUJADO DE LÍNEAS ──────────────────────────────────────────

func _draw():
	for l in _lineas_anim:
		var desde: Vector2 = l["desde"]
		var hasta: Vector2 = l["hasta"]
		var punto_actual   = desde.lerp(hasta, l["progreso"])
		draw_line(desde, punto_actual, COLOR_LINEA, GROSOR_LINEA, true)


# ─── CÁLCULO DE POSICIONES ───────────────────────────────────────

func _asignar_posicion(nodo, posiciones: Dictionary, indice: Array, nivel: int, altura_total: int):
	if nodo == null:
		return
	_asignar_posicion(nodo.izquierda, posiciones, indice, nivel + 1, altura_total)

	var vp         = get_viewport_rect().size
	var x_inicio   = vp.x / 2.0 + MARGEN_IZQ
	var ancho_util = vp.x / 2.0 - MARGEN_IZQ - MARGEN_DER
	var alto_util  = vp.y - MARGEN_TOP - MARGEN_BOT

	var x = x_inicio + (indice[0] + 0.5) / _total_nodos * ancho_util
	var y = MARGEN_TOP + (nivel + 0.5) / altura_total * alto_util

	posiciones[nodo.id] = Vector2(x, y)
	indice[0] += 1

	_asignar_posicion(nodo.derecha, posiciones, indice, nivel + 1, altura_total)


# ─── RECOLECCIÓN ─────────────────────────────────────────────────

func _recolectar_lineas(nodo, posiciones: Dictionary):
	if nodo == null:
		return
	var pos_padre = posiciones.get(nodo.id, Vector2.ZERO)
	for hijo in [nodo.izquierda, nodo.derecha]:
		if hijo != null:
			_lineas_anim.append({
				"desde":    pos_padre,
				"hasta":    posiciones.get(hijo.id, Vector2.ZERO),
				"progreso": 0.0
			})
			_recolectar_lineas(hijo, posiciones)


func _recolectar_nodos(nodo, posiciones: Dictionary):
	if nodo == null:
		return
	_draw_data.append({
		"pos":        posiciones.get(nodo.id, Vector2.ZERO),
		"es_nuevo":   nodo.id == _ultimo_id,
		"id":         nodo.id,
		"gravedad":   nodo.gravedad,
		"tipo_acoso": nodo.tipo_acoso,
		"ley":        nodo.ley,
		"pena":       nodo.pena
	})
	_recolectar_nodos(nodo.izquierda, posiciones)
	_recolectar_nodos(nodo.derecha, posiciones)


# ─── NODOS VISUALES ──────────────────────────────────────────────

func _crear_nodos_visuales(delay_base: float):
	for i in _draw_data.size():
		var d          = _draw_data[i]
		var pos: Vector2   = d["pos"]
		var es_nuevo: bool = d["es_nuevo"]

		var color_fondo = COLOR_NUEVO       if es_nuevo else COLOR_NODO
		var color_borde = COLOR_BORDE_NUEVO if es_nuevo else COLOR_BORDE

		var panel = Panel.new()
		panel.size         = Vector2(DIAMETRO, DIAMETRO)
		panel.position     = pos - Vector2(RADIO, RADIO)
		panel.pivot_offset = Vector2(RADIO, RADIO)
		panel.scale        = Vector2.ZERO
		panel.modulate.a   = 0.0

		var style = StyleBoxFlat.new()
		style.bg_color     = color_fondo
		style.border_color = color_borde
		style.set_border_width_all(int(GROSOR_BORDE))
		style.set_corner_radius_all(int(RADIO))
		style.anti_aliasing      = true
		style.anti_aliasing_size = 1.5
		panel.add_theme_stylebox_override("panel", style)
		add_child(panel)

		# Labels
		var vbox = VBoxContainer.new()
		vbox.size      = Vector2(DIAMETRO - 8, DIAMETRO - 8)
		vbox.position  = Vector2(4, 4)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(vbox)

		var lbl_id = Label.new()
		lbl_id.text = "#%d" % d["id"]
		lbl_id.add_theme_color_override("font_color", COLOR_TEXTO)
		lbl_id.add_theme_font_size_override("font_size", 15)
		lbl_id.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_id)

		var lbl_g = Label.new()
		lbl_g.text = "G: %d" % d["gravedad"]
		lbl_g.add_theme_color_override("font_color", COLOR_GRAV)
		lbl_g.add_theme_font_size_override("font_size", 11)
		lbl_g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_g)

		var lbl_tipo = Label.new()
		lbl_tipo.text = _primeras_palabras(d["tipo_acoso"], 2)
		lbl_tipo.add_theme_color_override("font_color", COLOR_TIPO)
		lbl_tipo.add_theme_font_size_override("font_size", 10)
		lbl_tipo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_tipo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_tipo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(lbl_tipo)

		# Hover: area invisible encima del nodo para detectar mouse
		var area = _crear_area_hover(pos, d, panel)
		add_child(area)

		# Tween de entrada
		var delay = delay_base + i * 0.08
		var tw = create_tween()
		tw.tween_interval(delay)
		tw.set_parallel(true)
		tw.tween_property(panel, "scale", Vector2.ONE, DURACION_NODO)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "modulate:a", 1.0, DURACION_NODO * 0.7)\
			.set_trans(Tween.TRANS_LINEAR)

		# Partículas al aparecer (feature 8)
		var delay_part = delay + DURACION_NODO * 0.3
		_lanzar_particulas(pos, color_fondo, color_borde, delay_part)

		# Pulso en el nodo nuevo (feature 3)
		if es_nuevo:
			_nodo_pulsando = panel
			var delay_pulso = delay + DURACION_NODO
			_iniciar_pulso(panel, delay_pulso)


# ─── PULSO (feature 3) ───────────────────────────────────────────

func _iniciar_pulso(panel: Panel, delay: float):
	if _tween_pulso != null and _tween_pulso.is_valid():
		_tween_pulso.kill()
	_tween_pulso = create_tween()
	_tween_pulso.tween_interval(delay)
	_tween_pulso.tween_property(panel, "scale",
		Vector2(PULSO_ESCALA, PULSO_ESCALA), PULSO_DURACION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_pulso.tween_property(panel, "scale",
		Vector2.ONE, PULSO_DURACION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_pulso.set_loops()   # Loop infinito hasta el siguiente redibujo


# ─── ÁREA DE HOVER (feature 4) ───────────────────────────────────

func _crear_area_hover(pos: Vector2, datos: Dictionary, _panel: Panel) -> Control:
	# Usamos un Control transparente cuadrado centrado en el nodo
	var area = Control.new()
	area.size          = Vector2(DIAMETRO, DIAMETRO)
	area.position      = pos - Vector2(RADIO, RADIO)
	area.mouse_filter  = Control.MOUSE_FILTER_STOP

	# Capturamos mouse_entered y mouse_exited via señales
	area.mouse_entered.connect(func(): _mostrar_tooltip(datos, pos))
	area.mouse_exited.connect(func(): _ocultar_tooltip())

	return area


# ─── PARTÍCULAS (feature 8) ──────────────────────────────────────

func _lanzar_particulas(pos: Vector2, color_centro: Color, color_borde: Color, delay: float):
	var part = CPUParticles2D.new()
	part.position        = pos
	part.emitting        = false
	part.one_shot        = true
	part.explosiveness   = 0.95     # Todas salen casi al mismo tiempo (burst)
	part.amount          = 18
	part.lifetime        = 0.70
	part.speed_scale     = 1.0

	# Dirección: radial hacia afuera en todas las direcciones
	part.emission_shape  = CPUParticles2D.EMISSION_SHAPE_SPHERE
	part.emission_sphere_radius = 5.0
	part.direction       = Vector2(0, -1)
	part.spread          = 180.0
	part.initial_velocity_min = 60.0
	part.initial_velocity_max = 130.0
	part.gravity         = Vector2(0, 80)

	# Tamaño: empieza grande y se encoge
	part.scale_amount_min  = 3.5
	part.scale_amount_max  = 6.0
	part.scale_amount_curve = _curva_decreciente()

	# Color: del color del borde al transparente
	var grad = Gradient.new()
	grad.set_color(0, color_borde.lightened(0.3))
	grad.add_point(0.4, color_centro.lightened(0.1))
	grad.add_point(1.0, Color(color_borde.r, color_borde.g, color_borde.b, 0.0))
	part.color_ramp = grad

	# Disparar con delay y autodestruir al terminar
	var tw = create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(func():
		add_child(part)
		part.emitting = true
	)
	tw.tween_interval(part.lifetime + 0.3)
	tw.tween_callback(func(): if is_instance_valid(part): part.queue_free())


func _curva_decreciente() -> Curve:
	var c = Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(1.0, 0.0))
	return c


# ─── HELPERS ─────────────────────────────────────────────────────

func _primeras_palabras(texto: String, n: int) -> String:
	var palabras = texto.split(" ")
	if palabras.size() <= n:
		return texto
	return " ".join(palabras.slice(0, n)) + "…"


func _altura(nodo) -> int:
	if nodo == null:
		return 0
	return 1 + max(_altura(nodo.izquierda), _altura(nodo.derecha))


func _contar_nodos(nodo) -> int:
	if nodo == null:
		return 0
	return 1 + _contar_nodos(nodo.izquierda) + _contar_nodos(nodo.derecha)
