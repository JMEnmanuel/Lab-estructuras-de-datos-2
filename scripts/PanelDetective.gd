extends CanvasLayer

# ─── NARRATIVA POR NIVEL ─────────────────────────────────────────
const NARRATIVA = [
	{
		"nivel":     "Nivel 1 — Las primeras señales",
		"situacion": "Valeria recibe mensajes ofensivos en redes sociales. Al principio parecen bromas, pero se repiten constantemente.",
		"objetivo":  "Recolectar capturas, identificar al agresor y clasificar el tipo de agresión."
	},
	{
		"nivel":     "Nivel 2 — El rumor viral",
		"situacion": "Circulan publicaciones falsas sobre Valeria que dañan su reputación.",
		"objetivo":  "Identificar la publicación original y rastrear quién inició el rumor."
	},
	{
		"nivel":     "Nivel 3 — La cuenta fantasma",
		"situacion": "Aparece un perfil falso con la foto de Valeria publicando contenido ofensivo.",
		"objetivo":  "Analizar el perfil, rastrear la IP de creación e identificar al responsable."
	},
	{
		"nivel":     "Nivel 4 — El ataque coordinado",
		"situacion": "Varias cuentas atacan a Valeria al mismo tiempo con comentarios humillantes.",
		"objetivo":  "Identificar patrones de comportamiento y al responsable principal."
	},
	{
		"nivel":     "Nivel Final — La verdad",
		"situacion": "El detective reúne todas las evidencias. La campaña de ciberacoso queda al descubierto.",
		"objetivo":  "Reconstruir la línea completa de los hechos."
	}
]

# ─── COLORES ─────────────────────────────────────────────────────
const COLOR_FONDO        := Color(0.04, 0.07, 0.14, 0.93)
const COLOR_BORDE        := Color(0.20, 0.45, 0.70, 0.70)
const COLOR_TITULO       := Color(0.55, 0.90, 1.00)
const COLOR_TEXTO        := Color(0.85, 0.92, 1.00)
const COLOR_TEXTO_DIM    := Color(0.55, 0.65, 0.80)
const COLOR_EVIDENCIA_OK := Color(0.20, 0.85, 0.50)
const COLOR_EVIDENCIA_NO := Color(0.40, 0.52, 0.68)
const COLOR_PROGRESO_BG  := Color(0.10, 0.18, 0.30)
const COLOR_PROGRESO_FG  := Color(0.20, 0.72, 0.95)
const COLOR_NIVEL        := Color(0.90, 0.75, 0.20)
const COLOR_LEY          := Color(0.90, 0.60, 0.30)
const COLOR_PENA         := Color(0.85, 0.40, 0.40)

# ─── NODOS ───────────────────────────────────────────────────────
var _raiz:             Control
var _panel:            PanelContainer
var _lbl_nivel:        Label
var _lbl_situacion:    Label
var _lbl_objetivo:     Label
var _contenedor_evid:  VBoxContainer
var _barra_progreso:   ProgressBar
var _lbl_progreso:     Label
var _lbl_ley:          Label
var _lbl_pena:         Label
var _sep_delito:       HSeparator
var _lbl_titulo_delito: Label

var _indice: int = 0
var _total:  int = 5


# ─── SETUP ───────────────────────────────────────────────────────

func _ready():
	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)

	_construir_panel()
	_panel.modulate.a = 0.0


func _construir_panel():
	_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color      = COLOR_FONDO
	style.border_color  = COLOR_BORDE
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.anti_aliasing = true
	_panel.add_theme_stylebox_override("panel", style)

	_panel.anchor_top    = 0.0
	_panel.anchor_bottom = 1.0
	_panel.anchor_left   = 0.0
	_panel.anchor_right  = 0.0
	_panel.offset_left   = 10
	_panel.offset_right  = 270
	_panel.offset_top    = 10
	_panel.offset_bottom = -10
	_raiz.add_child(_panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   10)
	margin.add_theme_constant_override("margin_right",  10)
	margin.add_theme_constant_override("margin_top",    10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	# — Detective —
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox)
	var icono = Label.new()
	icono.text = "🔍"
	icono.add_theme_font_size_override("font_size", 16)
	hbox.add_child(icono)
	var lbl_det = Label.new()
	lbl_det.text = "Detective Alex"
	lbl_det.add_theme_color_override("font_color", COLOR_TITULO)
	lbl_det.add_theme_font_size_override("font_size", 13)
	hbox.add_child(lbl_det)

	# — Progreso —
	vbox.add_child(_label_dim("CASOS INVESTIGADOS", 9))

	_barra_progreso = ProgressBar.new()
	_barra_progreso.min_value       = 0
	_barra_progreso.max_value       = _total
	_barra_progreso.value           = 0
	_barra_progreso.show_percentage = false
	_barra_progreso.custom_minimum_size = Vector2(0, 8)
	var sbg = StyleBoxFlat.new()
	sbg.bg_color = COLOR_PROGRESO_BG
	sbg.set_corner_radius_all(4)
	var sfg = StyleBoxFlat.new()
	sfg.bg_color = COLOR_PROGRESO_FG
	sfg.set_corner_radius_all(4)
	_barra_progreso.add_theme_stylebox_override("background", sbg)
	_barra_progreso.add_theme_stylebox_override("fill", sfg)
	vbox.add_child(_barra_progreso)

	_lbl_progreso = _label_color("0 / %d casos resueltos" % _total, COLOR_PROGRESO_FG, 10)
	vbox.add_child(_lbl_progreso)

	vbox.add_child(HSeparator.new())

	# — Nivel —
	_lbl_nivel = _label_color("", COLOR_NIVEL, 11)
	_lbl_nivel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_lbl_nivel)

	# — Situación —
	vbox.add_child(_label_dim("SITUACIÓN", 9))
	_lbl_situacion = _label_color("", COLOR_TEXTO, 10)
	_lbl_situacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_lbl_situacion)

	# — Objetivo —
	vbox.add_child(_label_dim("OBJETIVO", 9))
	_lbl_objetivo = _label_color("", COLOR_TEXTO, 10)
	_lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_lbl_objetivo)

	vbox.add_child(HSeparator.new())

	# — Evidencias —
	vbox.add_child(_label_dim("EVIDENCIAS", 9))
	_contenedor_evid = VBoxContainer.new()
	_contenedor_evid.add_theme_constant_override("separation", 3)
	vbox.add_child(_contenedor_evid)

	# — Delito (oculto hasta insertar) —
	_sep_delito = HSeparator.new()
	_sep_delito.visible = false
	vbox.add_child(_sep_delito)

	_lbl_titulo_delito = _label_dim("DELITO IDENTIFICADO", 9)
	_lbl_titulo_delito.visible = false
	vbox.add_child(_lbl_titulo_delito)

	_lbl_ley = _label_color("", COLOR_LEY, 10)
	_lbl_ley.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_ley.visible = false
	vbox.add_child(_lbl_ley)

	_lbl_pena = _label_color("", COLOR_PENA, 10)
	_lbl_pena.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_pena.visible = false
	vbox.add_child(_lbl_pena)


# ─── API PÚBLICA ─────────────────────────────────────────────────

func mostrar_caso(caso: NodoArbol, indice: int, evidencias_mezcladas: Array):
	_indice = indice

	_sep_delito.visible        = false
	_lbl_titulo_delito.visible = false
	_lbl_ley.visible           = false
	_lbl_pena.visible          = false

	var narr            = NARRATIVA[min(indice, NARRATIVA.size() - 1)]
	_lbl_nivel.text     = narr["nivel"]
	_lbl_situacion.text = narr["situacion"]
	_lbl_objetivo.text  = narr["objetivo"]

	_poblar_evidencias(evidencias_mezcladas, false)

	if _panel.modulate.a < 0.5:
		var tw = create_tween()
		tw.tween_property(_panel, "modulate:a", 1.0, 0.40)


func confirmar_insercion(caso: NodoArbol):
	_poblar_evidencias(caso.evidencias, true)

	_sep_delito.visible        = true
	_lbl_titulo_delito.visible = true
	_lbl_ley.text              = "⚖️  " + caso.ley
	_lbl_pena.text             = "🔒  " + caso.pena
	_lbl_ley.visible           = true
	_lbl_pena.visible          = true
	_lbl_ley.modulate.a        = 0.0
	_lbl_pena.modulate.a       = 0.0

	var tw = create_tween()
	tw.tween_property(_lbl_ley,  "modulate:a", 1.0, 0.35)
	tw.tween_property(_lbl_pena, "modulate:a", 1.0, 0.35)

	_actualizar_progreso(_indice + 1)


func mostrar_reporte_final():
	_lbl_nivel.text     = "🏆  Caso resuelto"
	_lbl_situacion.text = "Detective Alex ha reconstruido la línea completa de los hechos."
	_lbl_objetivo.text  = "Lo que comenzó como 'bromas' se convirtió en %d delitos reales." % _total
	_actualizar_progreso(_total)


# ─── PRIVADOS ────────────────────────────────────────────────────

func _poblar_evidencias(evidencias: Array, confirmadas: bool):
	for c in _contenedor_evid.get_children():
		c.queue_free()
	var delay = 0.0
	for evid in evidencias:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 5)
		var ic = Label.new()
		ic.text = "✓" if confirmadas else "○"
		ic.add_theme_color_override("font_color",
			COLOR_EVIDENCIA_OK if confirmadas else COLOR_EVIDENCIA_NO)
		ic.add_theme_font_size_override("font_size", 11)
		ic.custom_minimum_size = Vector2(12, 0)
		hbox.add_child(ic)
		var lbl = Label.new()
		lbl.text = evid
		lbl.add_theme_color_override("font_color",
			COLOR_TEXTO if confirmadas else COLOR_TEXTO_DIM)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		_contenedor_evid.add_child(hbox)
		if confirmadas:
			hbox.modulate.a = 0.0
			var tw = create_tween()
			tw.tween_property(hbox, "modulate:a", 1.0, 0.25).set_delay(delay)
			delay += 0.08


func _actualizar_progreso(resueltos: int):
	var tw = create_tween()
	tw.tween_property(_barra_progreso, "value", resueltos, 0.40)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_lbl_progreso.text = "%d / %d casos resueltos" % [resueltos, _total]


func _label_color(texto: String, color: Color, size: int) -> Label:
	var l = Label.new()
	l.text = texto
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	return l


func _label_dim(texto: String, size: int) -> Label:
	return _label_color(texto, COLOR_TEXTO_DIM, size)
