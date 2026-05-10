extends Node2D

@onready var arbol_visual = $ArbolVisual

var panel_detective:  CanvasLayer
var pantalla_nivel:   CanvasLayer
var _esperando_nivel: bool = false


func _ready():
	GestorJuego.inicializar()

	panel_detective = load("res://scripts/PanelDetective.gd").new()
	add_child(panel_detective)

	pantalla_nivel = load("res://scripts/PantallaNivel.gd").new()
	pantalla_nivel.nivel_listo.connect(_on_nivel_listo)
	add_child(pantalla_nivel)

	_mostrar_pantalla_nivel()


func _mostrar_pantalla_nivel():
	if GestorJuego.hay_siguiente_caso():
		_esperando_nivel = true
		GestorAudio.sonido_insertar()
		pantalla_nivel.mostrar_nivel(GestorJuego.indice_actual)


func _on_nivel_listo():
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

			if not GestorJuego.juego_terminado():
				# Hay más casos — sonido de caso resuelto y pasar al siguiente nivel
				GestorAudio.sonido_caso_resuelto()
				await get_tree().create_timer(1.8).timeout
				GestorAudio.sonido_nivel_completo()
				await get_tree().create_timer(0.6).timeout
				_mostrar_pantalla_nivel()
			else:
				# Último caso — fanfare final y reporte
				GestorAudio.sonido_juego_completo()
				await get_tree().create_timer(2.0).timeout
				panel_detective.mostrar_reporte_final()

	if event.keycode == KEY_R:
		GestorJuego.inicializar()
		arbol_visual.redibujar(null)
		_mostrar_pantalla_nivel()
