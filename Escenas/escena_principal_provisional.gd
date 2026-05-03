extends Node2D

@onready var arbol_visual = $ArbolVisual

var panel_detective:  CanvasLayer
var pantalla_nivel:   CanvasLayer
var _esperando_nivel: bool = false  # true = pantalla de nivel abierta, ignorar SPACE para árbol


func _ready():
	GestorJuego.inicializar()

	panel_detective = load("res://scripts/PanelDetective.gd").new()
	add_child(panel_detective)

	pantalla_nivel = load("res://scripts/PantallaNivel.gd").new()
	pantalla_nivel.nivel_listo.connect(_on_nivel_listo)
	add_child(pantalla_nivel)

	# Mostrar pantalla del primer nivel al arrancar
	_mostrar_pantalla_nivel()


func _mostrar_pantalla_nivel():
	if GestorJuego.hay_siguiente_caso():
		_esperando_nivel = true
		pantalla_nivel.mostrar_nivel(GestorJuego.indice_actual)


func _on_nivel_listo():
	# El jugador cerró la pantalla de nivel — mostrar el panel y habilitar inserción
	_esperando_nivel = false
	if GestorJuego.hay_siguiente_caso():
		var caso = GestorJuego.obtener_caso_actual()
		panel_detective.mostrar_caso(caso, GestorJuego.indice_actual,
			GestorJuego.obtener_evidencias_actuales())


func _input(event):
	if not (event is InputEventKey and event.pressed):
		return

	if event.keycode == KEY_SPACE and not _esperando_nivel:
		if GestorJuego.hay_siguiente_caso():
			var caso = GestorJuego.obtener_caso_actual()

			arbol_visual.capturar_posiciones_previas(ArbolAVL.raiz)
			GestorJuego.insertar_caso_actual()
			arbol_visual.redibujar(ArbolAVL.raiz, caso.id)
			panel_detective.confirmar_insercion(caso)

			if GestorJuego.hay_siguiente_caso():
				# Esperar, luego mostrar pantalla del siguiente nivel
				await get_tree().create_timer(1.8).timeout
				_mostrar_pantalla_nivel()
			else:
				await get_tree().create_timer(2.0).timeout
				panel_detective.mostrar_reporte_final()

	if event.keycode == KEY_R:
		GestorJuego.inicializar()
		arbol_visual.redibujar(null)
		_mostrar_pantalla_nivel()
