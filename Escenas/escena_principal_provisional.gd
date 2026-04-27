extends Node2D

@onready var arbol_visual = $ArbolVisual

func _ready():
	GestorJuego.inicializar()
	print("=== PRUEBA ÁRBOL VISUAL ===")
	print("Casos cargados: ", GestorJuego.casos.size())


func _input(event):
	# Presiona ESPACIO para insertar el siguiente caso
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if GestorJuego.hay_siguiente_caso():
			var caso = GestorJuego.obtener_caso_actual()
			GestorJuego.insertar_caso_actual()
			print("Insertado: Caso #%d — %s (gravedad %d)" % [caso.id, caso.tipo_acoso, caso.gravedad])
			print("Altura árbol: ", GestorJuego.obtener_altura_arbol())
			print("Balance raíz: ", GestorJuego.obtener_balance_raiz())
			arbol_visual.redibujar(ArbolAVL.raiz, caso.id)
		else:
			print("=== Todos los casos insertados ===")
			print(GestorJuego.obtener_reporte())

	# Presiona R para reiniciar
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		GestorJuego.inicializar()
		arbol_visual.redibujar(null)
		print("=== Árbol reiniciado ===")
