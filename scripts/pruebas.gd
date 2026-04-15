extends Node


func _ready():
	GestorJuego.inicializar()
	
	# Verificar que los casos se cargaron
	var caso = GestorJuego.obtener_caso_actual()
	print("Caso actual: ", caso.tipo_acoso)
	print("Gravedad: ", caso.gravedad)
	print("Evidencias: ", GestorJuego.obtener_evidencias_actuales())
	
	# Insertar todos los casos y verificar el árbol
	while GestorJuego.hay_siguiente_caso():
		GestorJuego.insertar_caso_actual()
	
	print("Altura del árbol: ", GestorJuego.obtener_altura_arbol())
	print("Balance de la raíz: ", GestorJuego.obtener_balance_raiz())
	
	# Verificar inorden (debe salir del 1 al 5)
	var inorden = ArbolAVL.obtener_inorden()
	for nodo in inorden:
		print("Caso #", nodo.id, " — ", nodo.tipo_acoso, " (gravedad ", nodo.gravedad, ")")
	
	# Reporte final
	print(GestorJuego.obtener_reporte())
