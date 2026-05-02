extends Node2D

# ─── CONFIGURACIÓN VISUAL ────────────────────────────────────────
const DIAMETRO     := 80.0
const RADIO        := DIAMETRO / 2.0
const COLOR_NODO         := Color(0.10, 0.22, 0.40)
const COLOR_BORDE        := Color(0.25, 0.72, 0.90)
const COLOR_TEXTO        := Color(1.0, 1.0, 1.0)
const COLOR_GRAV         := Color(0.55, 0.95, 1.0)
const COLOR_TIPO         := Color(0.78, 0.88, 1.0)
const COLOR_LINEA        := Color(0.55, 0.55, 0.65, 0.90)
const COLOR_NUEVO        := Color(0.12, 0.72, 0.38)
const COLOR_BORDE_NUEVO  := Color(0.40, 1.0, 0.60)
const COLOR_ROTACION     := Color(0.90, 0.70, 0.10)
const COLOR_BORDE_ROT    := Color(1.0, 0.90, 0.30)
const GROSOR_LINEA := 2.0
const GROSOR_BORDE := 2.5

# Gradiente de fondo
const COLOR_FONDO_TOP    := Color(0.03, 0.05, 0.12, 1.0)
const COLOR_FONDO_BOT    := Color(0.05, 0.12, 0.25, 1.0)
const COLOR_FONDO_PANEL  := Color(0.05, 0.08, 0.15, 0.75)
const COLOR_BORDE_PANEL  := Color(0.20, 0.40, 0.65, 0.60)

# Líneas con gradiente
const COLOR_LINEA_ORIG   := Color(0.35, 0.55, 0.85, 0.95)   # Azul brillante en origen
const COLOR_LINEA_DEST   := Color(0.20, 0.30, 0.50, 0.30)   # Azul apagado en destino
const PASOS_LINEA        := 12   # Segmentos para el gradiente

# Borde animado
const COLOR_BORDE_ANIM   := Color(0.40, 0.85, 1.0, 0.0)     # Empieza transparente
const RADIO_BORDE_ANIM   := DIAMETRO / 2.0 + 6.0

const MARGEN_TOP  := 60.0
const MARGEN_BOT  := 30.0
const MARGEN_IZQ  := 20.0
const MARGEN_DER  := 20.0
const SEP_MINIMA  := 95.0
const SEP_V_MINIMA := 110.0  # Separación vertical mínima entre niveles

# ─── TIEMPOS ─────────────────────────────────────────────────────
const DURACION_LINEA    := 0.80
const DURACION_NODO     := 0.45
const DELAY_NODO        := 0.20
const PULSO_ESCALA      := 1.08
const PULSO_DURACION    := 0.70
const DURACION_ROTACION := 0.70

# ─── TOOLTIP ─────────────────────────────────────────────────────
const COLOR_TOOLTIP_BG   := Color(0.05, 0.10, 0.20, 0.92)
const COLOR_TOOLTIP_BORD := Color(0.25, 0.72, 0.90, 0.80)
const COLOR_TOOLTIP_TEXT := Color(0.90, 0.95, 1.0)

# ─── ESTADO PERSISTENTE ──────────────────────────────────────────
var _paneles: Dictionary = {}
var _areas:   Dictionary = {}

# ─── ESTADO INTERNO ──────────────────────────────────────────────
var _ultimo_id: int        = -1
var _total_nodos: int      = 0
var _draw_data: Array      = []
var _lineas: Array         = []
var _ids_rotacion: Array   = []
var _tipo_rotacion: String = ""
var _posiciones_previas: Dictionary = {}
var _panel_fondo: Node    = null
var _tooltip:      Panel   = null
var _nodo_pulsando         = null
var _tween_pulso:  Tween   = null
var _nodos_aux:    Array   = []
var _lineas_siguen_paneles: bool = false
var _tiempo: float = 0.0
var _fondo_creado: bool = false   # Solo anima la primera vez


# ─── SETUP ───────────────────────────────────────────────────────

func _ready():
	ArbolAVL.rotacion_ocurrida.connect(_on_rotacion_ocurrida)
	set_process(true)


func _process(delta):
	if _lineas_siguen_paneles:
		queue_redraw()
	# El borde animado necesita redibujarse cada frame si hay nodos
	if _paneles.size() > 0:
		_tiempo += delta
		queue_redraw()


func _on_rotacion_ocurrida(tipo: String, ids: Array):
	_tipo_rotacion = tipo
	_ids_rotacion  = ids


# ─── API PÚBLICA ─────────────────────────────────────────────────

func capturar_posiciones_previas(raiz_arbol):
	_posiciones_previas.clear()
	if raiz_arbol == null:
		return
	var total  = _contar_nodos(raiz_arbol)
	var indice = [0]
	var altura = _altura(raiz_arbol)
	_calcular_posiciones(raiz_arbol, _posiciones_previas, indice, 0, altura, total)


func redibujar(raiz_arbol, ultimo_id: int = -1):
	_ultimo_id = ultimo_id
	_draw_data.clear()
	_lineas.clear()
	_lineas_siguen_paneles = false

	for n in _nodos_aux:
		if is_instance_valid(n):
			n.queue_free()
	_nodos_aux.clear()
	_tooltip = null

	if _tween_pulso != null and _tween_pulso.is_valid():
		_tween_pulso.kill()
	_nodo_pulsando = null

	if raiz_arbol == null:
		for id in _paneles:
			if is_instance_valid(_paneles[id]): _paneles[id].queue_free()
		for id in _areas:
			if is_instance_valid(_areas[id]): _areas[id].queue_free()
		_paneles.clear()
		_areas.clear()
		_ids_rotacion.clear()
		_fondo_creado = false
		# Animar salida del fondo al reiniciar
		if is_instance_valid(_panel_fondo):
			var vp_r = get_viewport_rect().size
			var fondo_ref = _panel_fondo
			_panel_fondo = null
			var tw_out = create_tween()
			tw_out.set_parallel(true)
			tw_out.tween_property(fondo_ref, "modulate:a", 0.0, 0.35)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tw_out.tween_property(fondo_ref, "position", Vector2(0, vp_r.y), 0.35)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tw_out.tween_callback(func(): if is_instance_valid(fondo_ref): fondo_ref.queue_free())
		queue_redraw()
		return

	_total_nodos = _contar_nodos(raiz_arbol)
	var posiciones_nuevas = {}
	var indice = [0]
	var altura = _altura(raiz_arbol)
	_calcular_posiciones(raiz_arbol, posiciones_nuevas, indice, 0, altura, _total_nodos)
	_recolectar_conexiones(raiz_arbol)
	_recolectar_nodos(raiz_arbol, posiciones_nuevas)

	_crear_fondo()
	_crear_tooltip()

	if _ids_rotacion.size() > 0:
		_ejecutar_con_rotacion(posiciones_nuevas)
	else:
		_ejecutar_normal(posiciones_nuevas)

	_ids_rotacion.clear()
	_tipo_rotacion = ""


# ─── DRAW ────────────────────────────────────────────────────────

func _draw():
	# ── Líneas con gradiente de opacidad ──
	for l in _lineas:
		var id_padre = l["id_padre"]
		var id_hijo  = l["id_hijo"]
		var progreso = l["progreso"]
		if not (_paneles.has(id_padre) and _paneles.has(id_hijo)):
			continue
		var panel_p = _paneles[id_padre]
		var panel_h = _paneles[id_hijo]
		if not (is_instance_valid(panel_p) and is_instance_valid(panel_h)):
			continue
		var desde       = panel_p.position + Vector2(RADIO, RADIO)
		var hasta       = panel_h.position + Vector2(RADIO, RADIO)
		var punto_final = desde.lerp(hasta, progreso)
		# Dibujar en segmentos con alpha interpolado
		for i in PASOS_LINEA:
			var t0 = float(i) / PASOS_LINEA
			var t1 = float(i + 1) / PASOS_LINEA
			if t1 > progreso: t1 = progreso
			if t0 >= progreso: break
			var p0    = desde.lerp(punto_final, t0)
			var p1    = desde.lerp(punto_final, t1)
			var color = COLOR_LINEA_ORIG.lerp(COLOR_LINEA_DEST, t0)
			draw_line(p0, p1, color, GROSOR_LINEA, true)

	# ── Bordes animados (pulso de opacidad) ──
	for id in _paneles:
		var panel = _paneles[id]
		if not is_instance_valid(panel): continue
		var centro = panel.position + Vector2(RADIO, RADIO)
		# Onda senoidal desfasada por id para que no pulsen todos igual
		var fase   = _tiempo * 2.0 + id * 0.8
		var alpha  = (sin(fase) * 0.5 + 0.5) * 0.55
		var color  = Color(COLOR_BORDE_ANIM.r, COLOR_BORDE_ANIM.g, COLOR_BORDE_ANIM.b, alpha)
		draw_arc(centro, RADIO_BORDE_ANIM, 0, TAU, 48, color, 2.0, true)


# ─── FLUJO NORMAL ────────────────────────────────────────────────

func _ejecutar_normal(posiciones_nuevas: Dictionary):
	var ids_validos = _draw_data.map(func(d): return d["id"])
	_limpiar_paneles_obsoletos(ids_validos)

	# Recrear áreas solo para nodos EXISTENTES (el nuevo las crea en _crear_panel_nuevo)
	_recrear_areas_existentes(posiciones_nuevas)

	for i in _lineas.size():
		_lineas[i]["progreso"] = 0.0

	var delay_acum := 0.0
	for i in _lineas.size():
		var tw = create_tween()
		tw.tween_interval(delay_acum)
		tw.tween_method(
			func(v): if i < _lineas.size(): _lineas[i]["progreso"] = v; queue_redraw(),
			0.0, 1.0, DURACION_LINEA
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		delay_acum += 0.05

	var delay_nodo = delay_acum + DURACION_LINEA + DELAY_NODO
	for d in _draw_data:
		if d["es_nuevo"]:
			_crear_panel_nuevo(d, delay_nodo)


# ─── FLUJO CON ROTACIÓN ──────────────────────────────────────────

func _ejecutar_con_rotacion(posiciones_nuevas: Dictionary):
	var ids_validos = _draw_data.map(func(d): return d["id"])
	_limpiar_paneles_obsoletos(ids_validos)

	# Recrear áreas solo para nodos EXISTENTES
	_recrear_areas_existentes(posiciones_nuevas)

	for i in _lineas.size():
		_lineas[i]["progreso"] = 1.0
	_lineas_siguen_paneles = true

	var delay_resalte := 0.05
	for id in _ids_rotacion:
		if _paneles.has(id):
			_cambiar_color_panel(_paneles[id], COLOR_ROTACION, COLOR_BORDE_ROT, delay_resalte)

	_mostrar_etiqueta_rotacion(delay_resalte)

	var delay_mover := delay_resalte + 0.30
	for id in _paneles:
		if posiciones_nuevas.has(id) and is_instance_valid(_paneles[id]):
			var pos_nueva = posiciones_nuevas[id] - Vector2(RADIO, RADIO)
			var tw = create_tween()
			tw.tween_interval(delay_mover)
			tw.tween_property(_paneles[id], "position", pos_nueva, DURACION_ROTACION)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		if _areas.has(id) and posiciones_nuevas.has(id) and is_instance_valid(_areas[id]):
			var tw2 = create_tween()
			tw2.tween_interval(delay_mover)
			tw2.tween_property(_areas[id], "position",
				posiciones_nuevas[id] - Vector2(RADIO, RADIO), DURACION_ROTACION)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	var delay_restaurar := delay_mover + DURACION_ROTACION + 0.05
	for id in _ids_rotacion:
		if _paneles.has(id):
			var es_nuevo = (id == _ultimo_id)
			_cambiar_color_panel(_paneles[id],
				COLOR_NUEVO if es_nuevo else COLOR_NODO,
				COLOR_BORDE_NUEVO if es_nuevo else COLOR_BORDE,
				delay_restaurar)

	var tw_stop = create_tween()
	tw_stop.tween_interval(delay_restaurar + 0.05)
	tw_stop.tween_callback(func(): _lineas_siguen_paneles = false)

	var delay_nuevo := delay_restaurar + 0.15
	for d in _draw_data:
		if d["es_nuevo"]:
			_crear_panel_nuevo(d, delay_nuevo)


# ─── CREACIÓN DE PANEL NUEVO ─────────────────────────────────────

func _crear_panel_nuevo(d: Dictionary, delay: float):
	var pos: Vector2 = d["pos"]

	# Si ya existía un área para este id (de _recrear_areas), eliminarla primero
	if _areas.has(d["id"]) and is_instance_valid(_areas[d["id"]]):
		_areas[d["id"]].queue_free()
		_areas.erase(d["id"])

	var panel = Panel.new()
	panel.size         = Vector2(DIAMETRO, DIAMETRO)
	panel.position     = pos - Vector2(RADIO, RADIO)
	panel.pivot_offset = Vector2(RADIO, RADIO)
	panel.scale        = Vector2.ZERO
	panel.modulate.a   = 0.0
	panel.add_theme_stylebox_override("panel", _crear_style(COLOR_NUEVO, COLOR_BORDE_NUEVO))
	add_child(panel)
	_paneles[d["id"]] = panel
	panel.add_child(_crear_vbox(d))

	var area = _crear_area_hover(pos, d)
	add_child(area)
	_areas[d["id"]] = area

	var tw = create_tween()
	tw.tween_interval(delay)
	tw.set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, DURACION_NODO)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, DURACION_NODO * 0.7)

	_nodo_pulsando = panel
	_lanzar_particulas(pos, COLOR_NUEVO, COLOR_BORDE_NUEVO, delay + DURACION_NODO * 0.3)
	_iniciar_pulso(panel, delay + DURACION_NODO)


# ─── HELPERS DE PANELES ──────────────────────────────────────────

# Recrea áreas solo para nodos que YA EXISTEN en _paneles (no el nuevo)
func _recrear_areas_existentes(posiciones_nuevas: Dictionary):
	for id in _areas:
		if is_instance_valid(_areas[id]):
			_areas[id].queue_free()
	_areas.clear()

	for d in _draw_data:
		if d["es_nuevo"]:
			continue   # El nuevo crea su área en _crear_panel_nuevo
		var pos = posiciones_nuevas.get(d["id"], Vector2.ZERO)
		var area = _crear_area_hover(pos, d)
		add_child(area)
		_areas[d["id"]] = area


func _limpiar_paneles_obsoletos(ids_validos: Array):
	var a_eliminar = []
	for id in _paneles:
		if id not in ids_validos:
			if is_instance_valid(_paneles[id]): _paneles[id].queue_free()
			a_eliminar.append(id)
	for id in a_eliminar:
		_paneles.erase(id)
		if _areas.has(id):
			if is_instance_valid(_areas[id]): _areas[id].queue_free()
			_areas.erase(id)


func _cambiar_color_panel(panel: Panel, cf: Color, cb: Color, delay: float):
	var tw = create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(func():
		if is_instance_valid(panel):
			panel.add_theme_stylebox_override("panel", _crear_style(cf, cb))
	)


# ─── FONDO ───────────────────────────────────────────────────────

func _crear_fondo():
	# Solo se crea una vez
	if _fondo_creado and is_instance_valid(_panel_fondo):
		return
	_fondo_creado = true

	var vp = get_viewport_rect().size

	var shader_code = """
shader_type canvas_item;
uniform vec4 color_top : source_color = vec4(0.03, 0.05, 0.12, 1.0);
uniform vec4 color_bot : source_color = vec4(0.05, 0.12, 0.25, 1.0);
void fragment() {
	COLOR = mix(color_top, color_bot, UV.y);
}
"""
	var shader = Shader.new()
	shader.code = shader_code
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("color_top", COLOR_FONDO_TOP)
	mat.set_shader_parameter("color_bot", COLOR_FONDO_BOT)

	var rect = ColorRect.new()
	rect.size       = Vector2(vp.x, vp.y)
	rect.z_index    = -1
	rect.material   = mat
	# Empieza desde abajo de la pantalla
	rect.position   = Vector2(0, vp.y)
	rect.modulate.a = 0.0
	add_child(rect)
	# NO se agrega a _nodos_aux — el fondo persiste entre redraws
	_panel_fondo = rect

	# Entrada: sube desde abajo hasta su lugar + fade in
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(rect, "position", Vector2(0, 0), 0.70)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(rect, "modulate:a", 1.0, 0.55)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# ─── TOOLTIP ─────────────────────────────────────────────────────

func _crear_tooltip():
	_tooltip = Panel.new()
	_tooltip.visible      = false
	_tooltip.z_index      = 10
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color     = COLOR_TOOLTIP_BG
	style.border_color = COLOR_TOOLTIP_BORD
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.anti_aliasing = true
	_tooltip.add_theme_stylebox_override("panel", style)
	var vbox = VBoxContainer.new()
	vbox.name     = "VBox"
	vbox.position = Vector2(10, 8)
	_tooltip.add_child(vbox)
	for nombre in ["LblTitulo", "LblLey", "LblPena"]:
		var lbl = Label.new()
		lbl.name = nombre
		lbl.add_theme_color_override("font_color", COLOR_TOOLTIP_TEXT)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(lbl)
	add_child(_tooltip)
	_nodos_aux.append(_tooltip)


func _mostrar_tooltip(datos: Dictionary, pos_nodo: Vector2):
	if _tooltip == null: return
	var vbox = _tooltip.get_node("VBox")
	vbox.get_node("LblTitulo").text = "📋 %s" % datos["tipo_acoso"]
	vbox.get_node("LblLey").text    = "⚖️ %s" % datos["ley"]
	vbox.get_node("LblPena").text   = "🔒 %s" % datos["pena"]
	var ancho = 280.0
	var alto  = 100.0
	_tooltip.size = Vector2(ancho, alto)
	vbox.size     = Vector2(ancho - 20, alto - 16)
	var vp = get_viewport_rect().size
	var tx = pos_nodo.x + RADIO + 10
	var ty = clamp(pos_nodo.y - alto / 2.0, 5, vp.y - alto - 5)
	if tx + ancho > vp.x: tx = pos_nodo.x - RADIO - ancho - 10
	_tooltip.position   = Vector2(tx, ty)
	_tooltip.modulate.a = 0.0
	_tooltip.visible    = true
	var tw = create_tween()
	tw.tween_property(_tooltip, "modulate:a", 1.0, 0.18)


func _ocultar_tooltip():
	if _tooltip == null or not _tooltip.visible: return
	var tw = create_tween()
	tw.tween_property(_tooltip, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func(): if _tooltip != null: _tooltip.visible = false)


# ─── ETIQUETA ROTACIÓN ───────────────────────────────────────────

func _mostrar_etiqueta_rotacion(delay: float):
	var nombres = {"LL": "Rotación Derecha (LL)", "RR": "Rotación Izquierda (RR)",
		"LR": "Rotación Izq-Der (LR)", "RL": "Rotación Der-Izq (RL)"}
	var vp   = get_viewport_rect().size
	var etiq = Label.new()
	etiq.text = "⚖️ " + nombres.get(_tipo_rotacion, "Rotación AVL")
	etiq.add_theme_color_override("font_color", COLOR_ROTACION)
	etiq.add_theme_font_size_override("font_size", 14)
	etiq.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiq.size     = Vector2(vp.x - 20, 30)
	etiq.position = Vector2(10, 20)
	etiq.modulate.a = 0.0
	add_child(etiq)
	_nodos_aux.append(etiq)
	var tw = create_tween()
	tw.tween_interval(delay)
	tw.tween_property(etiq, "modulate:a", 1.0, 0.20)
	tw.tween_interval(1.80)
	tw.tween_property(etiq, "modulate:a", 0.0, 0.30)
	tw.tween_callback(func():
		if is_instance_valid(etiq): etiq.queue_free()
		_nodos_aux.erase(etiq)
	)


# ─── RECOLECCIÓN ─────────────────────────────────────────────────

func _recolectar_conexiones(nodo):
	if nodo == null: return
	for hijo in [nodo.izquierda, nodo.derecha]:
		if hijo != null:
			_lineas.append({"id_padre": nodo.id, "id_hijo": hijo.id, "progreso": 0.0})
			_recolectar_conexiones(hijo)


func _recolectar_nodos(nodo, posiciones: Dictionary):
	if nodo == null: return
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


# ─── POSICIONAMIENTO ─────────────────────────────────────────────

# Entrada principal — ignora indice/total, usa posicionamiento por padre
func _calcular_posiciones(raiz, posiciones: Dictionary, _indice: Array, _nivel: int, _altura_total: int, _total: int):
	if raiz == null: return
	var vp       = get_viewport_rect().size
	var cx       = vp.x / 2.0   # Centro de toda la pantalla
	var alto_util = vp.y - MARGEN_TOP - MARGEN_BOT
	var altura    = _altura(raiz)
	# Mitad del ancho disponible para el nivel raíz
	var mitad_ancho = (vp.x - MARGEN_IZQ - MARGEN_DER) / 4.0
	_pos_recursivo(raiz, posiciones, cx, 0, altura, alto_util, mitad_ancho)


func _pos_recursivo(nodo, posiciones: Dictionary, cx: float, nivel: int, altura_total: int, alto_util: float, offset_x: float):
	if nodo == null: return
	var vp = get_viewport_rect().size
	var y  = MARGEN_TOP + (nivel + 0.5) / float(altura_total) * alto_util
	posiciones[nodo.id] = Vector2(cx, y)

	# Separación mínima garantizada: el offset nunca baja de SEP_MINIMA/2
	var next_offset = max(offset_x / 2.0, SEP_MINIMA / 2.0)
	_pos_recursivo(nodo.izquierda, posiciones, cx - offset_x, nivel + 1, altura_total, alto_util, next_offset)
	_pos_recursivo(nodo.derecha,   posiciones, cx + offset_x, nivel + 1, altura_total, alto_util, next_offset)


func _nodos_en_nivel(raiz, nivel_objetivo: int, nivel_actual: int = 0) -> int:
	if raiz == null: return 0
	if nivel_actual == nivel_objetivo: return 1
	return _nodos_en_nivel(raiz.izquierda, nivel_objetivo, nivel_actual + 1) + \
		   _nodos_en_nivel(raiz.derecha, nivel_objetivo, nivel_actual + 1)


# ─── HELPERS DE CREACIÓN ─────────────────────────────────────────

func _crear_style(cf: Color, cb: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = cf; s.border_color = cb
	s.set_border_width_all(int(GROSOR_BORDE))
	s.set_corner_radius_all(int(RADIO))
	s.anti_aliasing = true; s.anti_aliasing_size = 1.5
	return s


func _crear_vbox(d: Dictionary) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.size = Vector2(DIAMETRO - 8, DIAMETRO - 8)
	vbox.position = Vector2(4, 4)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var lbl_id = Label.new()
	lbl_id.text = "#%d" % d["id"]
	lbl_id.add_theme_color_override("font_color", COLOR_TEXTO)
	lbl_id.add_theme_font_size_override("font_size", 13)
	lbl_id.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_id)
	var lbl_g = Label.new()
	lbl_g.text = "G: %d" % d["gravedad"]
	lbl_g.add_theme_color_override("font_color", COLOR_GRAV)
	lbl_g.add_theme_font_size_override("font_size", 10)
	lbl_g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_g)
	var lbl_tipo = Label.new()
	lbl_tipo.text = _primeras_palabras(d["tipo_acoso"], 2)
	lbl_tipo.add_theme_color_override("font_color", COLOR_TIPO)
	lbl_tipo.add_theme_font_size_override("font_size", 9)
	lbl_tipo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_tipo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_tipo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(lbl_tipo)
	return vbox


func _crear_area_hover(pos: Vector2, datos: Dictionary) -> Control:
	var area = Control.new()
	area.size = Vector2(DIAMETRO, DIAMETRO)
	area.position = pos - Vector2(RADIO, RADIO)
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	var pos_copia   = Vector2(pos.x, pos.y)
	var datos_copia = datos.duplicate(true)
	area.mouse_entered.connect(func(): _mostrar_tooltip(datos_copia, pos_copia))
	area.mouse_exited.connect(func():  _ocultar_tooltip())
	return area


# ─── PULSO ───────────────────────────────────────────────────────

func _iniciar_pulso(panel: Panel, delay: float):
	if _tween_pulso != null and _tween_pulso.is_valid():
		_tween_pulso.kill()
	_tween_pulso = create_tween()
	_tween_pulso.tween_interval(delay)
	_tween_pulso.tween_property(panel, "scale", Vector2(PULSO_ESCALA, PULSO_ESCALA), PULSO_DURACION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_pulso.tween_property(panel, "scale", Vector2.ONE, PULSO_DURACION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_pulso.set_loops()


# ─── PARTÍCULAS ──────────────────────────────────────────────────

func _lanzar_particulas(pos: Vector2, color_centro: Color, color_borde: Color, delay: float):
	var part = CPUParticles2D.new()
	part.position = pos; part.emitting = false; part.one_shot = true
	part.explosiveness = 0.95; part.amount = 18; part.lifetime = 0.70
	part.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	part.emission_sphere_radius = 5.0
	part.direction = Vector2(0, -1); part.spread = 180.0
	part.initial_velocity_min = 60.0; part.initial_velocity_max = 130.0
	part.gravity = Vector2(0, 80)
	part.scale_amount_min = 3.5; part.scale_amount_max = 6.0
	part.scale_amount_curve = _curva_decreciente()
	var grad = Gradient.new()
	grad.set_color(0, color_borde.lightened(0.3))
	grad.add_point(0.4, color_centro.lightened(0.1))
	grad.add_point(1.0, Color(color_borde.r, color_borde.g, color_borde.b, 0.0))
	part.color_ramp = grad
	var tw = create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(func(): add_child(part); part.emitting = true)
	tw.tween_interval(part.lifetime + 0.3)
	tw.tween_callback(func(): if is_instance_valid(part): part.queue_free())


func _curva_decreciente() -> Curve:
	var c = Curve.new()
	c.add_point(Vector2(0.0, 1.0)); c.add_point(Vector2(1.0, 0.0))
	return c


# ─── HELPERS ─────────────────────────────────────────────────────

func _primeras_palabras(texto: String, n: int) -> String:
	var palabras = texto.split(" ")
	if palabras.size() <= n: return texto
	return " ".join(palabras.slice(0, n)) + "…"

func _altura(nodo) -> int:
	if nodo == null: return 0
	return 1 + max(_altura(nodo.izquierda), _altura(nodo.derecha))

func _contar_nodos(nodo) -> int:
	if nodo == null: return 0
	return 1 + _contar_nodos(nodo.izquierda) + _contar_nodos(nodo.derecha)
