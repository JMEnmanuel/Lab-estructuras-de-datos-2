extends Node

var arbol
var casos: Array
var indice_actual: int = 0
var evidencias_mostradas: Array


func inicializar():
	arbol = ArbolAVL
	arbol.raiz = null
	casos = CasosJuego.obtener_casos()
	indice_actual = 0
	_mezclar_evidencias()


# Mezcla las evidencias del caso actual para el componente aleatorio
func _mezclar_evidencias():
	var caso = casos[indice_actual]
	evidencias_mostradas = caso.evidencias.duplicate()
	evidencias_mostradas.shuffle()


func obtener_caso_actual() -> NodoArbol:
	if indice_actual < casos.size():
		return casos[indice_actual]
	return null


func obtener_evidencias_actuales() -> Array:
	return evidencias_mostradas


# El jugador inserta el caso actual al árbol
func insertar_caso_actual():
	var caso = casos[indice_actual]
	arbol.insertar(caso)
	indice_actual += 1
	if indice_actual < casos.size():
		_mezclar_evidencias()


func hay_siguiente_caso() -> bool:
	return indice_actual < casos.size()


func juego_terminado() -> bool:
	return indice_actual >= casos.size()


func obtener_reporte() -> String:
	return arbol.generar_reporte()


func obtener_balance_raiz() -> int:
	return arbol._obtener_balance(arbol.raiz)


func obtener_altura_arbol() -> int:
	return arbol._obtener_altura(arbol.raiz)
