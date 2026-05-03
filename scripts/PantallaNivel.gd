extends CanvasLayer

# ─── DATOS POR NIVEL ─────────────────────────────────────────────
const NIVELES = [
	{
		"numero":   "Nivel 1",
		"titulo":   "Las primeras señales",
		"icono":    "📱",
		"situacion": "Valeria comienza a recibir mensajes ofensivos en redes sociales. Al principio parecen bromas aisladas, pero se repiten constantemente.",
		"objetivo": [
			"Recolectar capturas de pantalla de los mensajes",
			"Identificar el usuario que envía los mensajes",
			"Clasificar el tipo de agresión"
		],
		"delito":   "Injuria — Art. 220 del Código Penal Colombiano"
	},
	{
		"numero":   "Nivel 2",
		"titulo":   "El rumor viral",
		"icono":    "📢",
		"situacion": "Empiezan a circular publicaciones falsas sobre Valeria en redes sociales. Algunos estudiantes comparten rumores que dañan su reputación.",
		"objetivo": [
			"Identificar la publicación original",
			"Rastrear quién inició el rumor",
			"Determinar si se trata de información falsa"
		],
		"delito":   "Calumnia — Art. 221 del Código Penal Colombiano"
	},
	{
		"numero":   "Nivel 3",
		"titulo":   "La cuenta fantasma",
		"icono":    "👻",
		"situacion": "Aparece un perfil falso que utiliza la foto de Valeria para publicar contenido ofensivo y hacer comentarios agresivos a otros usuarios.",
		"objetivo": [
			"Analizar la información del perfil falso",
			"Rastrear la dirección IP de creación",
			"Identificar quién está detrás de la suplantación"
		],
		"delito":   "Suplantación — Ley 1273 de 2009"
	},
	{
		"numero":   "Nivel 4",
		"titulo":   "El ataque coordinado",
		"icono":    "⚡",
		"situacion": "El acoso se intensifica. Varias cuentas comienzan a atacar a Valeria al mismo tiempo con comentarios ofensivos y publicaciones humillantes.",
		"objetivo": [
			"Identificar qué cuentas pertenecen a la misma persona",
			"Encontrar patrones de comportamiento",
			"Identificar al responsable principal"
		],
		"delito":   "Hostigamiento reiterado — Ley 1273 de 2009"
	},
	{
		"numero":   "Nivel Final",
		"titulo":   "La verdad detrás del acoso",
		"icono":    "🏆",
		"situacion": "El detective logra reunir todas las evidencias almacenadas en el árbol. La campaña sostenida de ciberacoso queda al descubierto.",
		"objetivo": [
			"Recorrer el árbol completo de incidentes",
			"Analizar todos los nodos y sus conexiones",
			"Reconstruir la línea completa de los hechos"
		],
		"delito":   "Arts. 220, 221 C.P. + Ley 1273 de 2009"
	}
]

# ─── COLORES ─────────────────────────────────────────────────────
const COLOR_FONDO      := Color(0.02, 0.04, 0.10, 0.92)
const COLOR_ACENTO     := Color(0.20, 0.72, 0.95)
const COLOR_TITULO     := Color(1.00, 1.00, 1.00)
const COLOR_NUMERO     := Color(0.90, 0.75, 0.20)
const COLOR_TEXTO      := Color(0.80, 0.88, 1.00)
const COLOR_DIM        := Color(0.55, 0.65, 0.80)
const COLOR_OBJETIVO   := Color(0.20, 0.85, 0.50)
const COLOR_DELITO     := Color(0.90, 0.60, 0.30)
const COLOR_HINT       := Color(0.40, 0.50, 0.65)

# ─── SEÑAL ───────────────────────────────────────────────────────
signal nivel_listo  # Se emite cuando el jugador presiona SPACE para continuar

# ─── ESTADO ──────────────────────────────────────────────────────
var _visible_panel: bool = false
var _raiz:  Control
var _fondo: ColorRect
var _panel: PanelContainer


func _ready():
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)

	# Fondo semitransparente que cubre toda la pantalla
	_fondo = ColorRect.new()
	_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fondo.color = COLOR_FONDO
	_fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_fondo)

	_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color     = Color(0.05, 0.10, 0.20, 0.98)
	style.border_color = COLOR_ACENTO
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.anti_aliasing = true
	_panel.add_theme_stylebox_override("panel", style)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.anchor_left   = 0.5
	_panel.anchor_right  = 0.5
	_panel.anchor_top    = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left   = -320.0
	_panel.offset_right  =  320.0
	_panel.offset_top    = -260.0
	_panel.offset_bottom =  260.0
	_raiz.add_child(_panel)

	_raiz.visible = false


func _input(event):
	if _visible_panel and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_ocultar()
		nivel_listo.emit()


# ─── API PÚBLICA ─────────────────────────────────────────────────

func mostrar_nivel(indice: int):
	var datos = NIVELES[min(indice, NIVELES.size() - 1)]
	_construir_contenido(datos)
	_raiz.visible  = true
	_visible_panel = true
	_panel.modulate.a = 0.0
	_fondo.modulate.a = 0.0
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(_fondo,  "modulate:a", 1.0, 0.30)
	tw.tween_property(_panel,  "modulate:a", 1.0, 0.40)


func _ocultar():
	_visible_panel = false
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(_fondo,  "modulate:a", 0.0, 0.25)
	tw.tween_property(_panel,  "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(func(): _raiz.visible = false)


# ─── CONSTRUCCIÓN DE CONTENIDO ───────────────────────────────────

func _construir_contenido(datos: Dictionary):
	# Limpiar contenido anterior
	for c in _panel.get_children():
		c.queue_free()

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   30)
	margin.add_theme_constant_override("margin_right",  30)
	margin.add_theme_constant_override("margin_top",    28)
	margin.add_theme_constant_override("margin_bottom", 24)
	_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	# — Número y título —
	var hbox_titulo = HBoxContainer.new()
	hbox_titulo.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox_titulo)

	var lbl_icono = Label.new()
	lbl_icono.text = datos["icono"]
	lbl_icono.add_theme_font_size_override("font_size", 32)
	hbox_titulo.add_child(lbl_icono)

	var vbox_titulo = VBoxContainer.new()
	vbox_titulo.add_theme_constant_override("separation", 2)
	hbox_titulo.add_child(vbox_titulo)

	var lbl_numero = Label.new()
	lbl_numero.text = datos["numero"]
	lbl_numero.add_theme_color_override("font_color", COLOR_NUMERO)
	lbl_numero.add_theme_font_size_override("font_size", 13)
	vbox_titulo.add_child(lbl_numero)

	var lbl_titulo = Label.new()
	lbl_titulo.text = datos["titulo"]
	lbl_titulo.add_theme_color_override("font_color", COLOR_TITULO)
	lbl_titulo.add_theme_font_size_override("font_size", 22)
	vbox_titulo.add_child(lbl_titulo)

	# — Separador —
	var sep = HSeparator.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = COLOR_ACENTO
	sep_style.content_margin_top = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(sep)

	# — Situación —
	var lbl_sit_tag = _tag("SITUACIÓN")
	vbox.add_child(lbl_sit_tag)

	var lbl_situacion = Label.new()
	lbl_situacion.text = datos["situacion"]
	lbl_situacion.add_theme_color_override("font_color", COLOR_TEXTO)
	lbl_situacion.add_theme_font_size_override("font_size", 13)
	lbl_situacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_situacion)

	# — Objetivos —
	var lbl_obj_tag = _tag("OBJETIVOS DEL DETECTIVE")
	vbox.add_child(lbl_obj_tag)

	var vbox_obj = VBoxContainer.new()
	vbox_obj.add_theme_constant_override("separation", 5)
	vbox.add_child(vbox_obj)

	for obj in datos["objetivo"]:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		var bullet = Label.new()
		bullet.text = "▸"
		bullet.add_theme_color_override("font_color", COLOR_OBJETIVO)
		bullet.add_theme_font_size_override("font_size", 13)
		hbox.add_child(bullet)
		var lbl_obj = Label.new()
		lbl_obj.text = obj
		lbl_obj.add_theme_color_override("font_color", COLOR_TEXTO)
		lbl_obj.add_theme_font_size_override("font_size", 13)
		lbl_obj.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_obj.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl_obj)
		vbox_obj.add_child(hbox)

	# — Delito —
	var lbl_delito_tag = _tag("DELITO A INVESTIGAR")
	vbox.add_child(lbl_delito_tag)

	var hbox_delito = HBoxContainer.new()
	hbox_delito.add_theme_constant_override("separation", 8)
	var ic_delito = Label.new()
	ic_delito.text = "⚖️"
	ic_delito.add_theme_font_size_override("font_size", 14)
	hbox_delito.add_child(ic_delito)
	var lbl_delito = Label.new()
	lbl_delito.text = datos["delito"]
	lbl_delito.add_theme_color_override("font_color", COLOR_DELITO)
	lbl_delito.add_theme_font_size_override("font_size", 13)
	lbl_delito.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_delito.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_delito.add_child(lbl_delito)
	vbox.add_child(hbox_delito)

	# — Hint SPACE —
	var lbl_hint = Label.new()
	lbl_hint.text = "— Presiona SPACE para comenzar la investigación —"
	lbl_hint.add_theme_color_override("font_color", COLOR_HINT)
	lbl_hint.add_theme_font_size_override("font_size", 11)
	lbl_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_hint)


func _tag(texto: String) -> Label:
	var l = Label.new()
	l.text = texto
	l.add_theme_color_override("font_color", COLOR_DIM)
	l.add_theme_font_size_override("font_size", 10)
	return l
