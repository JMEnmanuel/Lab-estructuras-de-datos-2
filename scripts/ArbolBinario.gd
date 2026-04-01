extends Node


var raiz: NodoArbol
var nodo_actual: NodoArbol


func _init():
	_construir_arbol()
	_asignar_nodo_seguro()
	
	

func _construir_arbol():
	raiz = NodoArbol.new("","", {})
	
	raiz.izquierda = NodoArbol.new("","", {})
	raiz.derecha = NodoArbol.new("","", {})
	
	raiz.izquierda.izquierda = NodoArbol.new("","", {})
	raiz.izquierda.derecha = NodoArbol.new("","", {})
	raiz.izquierda.derecha = NodoArbol.new("","", {})
	raiz.derecha.derecha = NodoArbol.new("","", {})
	
	nodo_actual = raiz
	
	
func _obtener_todos_los_nodos(nodo: NodoArbol) -> Array:
	if nodo == null:
		return[]
	return [nodo] + _obtener_todos_los_nodos(nodo.izquierda)\
				  + _obtener_todos_los_nodos(nodo.derecha)

func _obtener_hojas(nodo: NodoArbol) -> Array:
	if nodo == null:
		return []
	if nodo.izquierda == null and nodo.derecha == null:
		return [nodo]
	return _obtener_hojas(nodo.izquierda) + _obtener_hojas(nodo.derecha)


func _asignar_nodo_seguro():
	var hojas = _obtener_hojas(raiz)
	var elegido = hojas[randi() % hojas.size()]
	elegido.es_seguro = true
	
func _moverse(direccion: String) -> NodoArbol:
	if direccion == "izquierda" and nodo_actual.izquierda != null:
		nodo_actual = nodo_actual.izquierda
	elif direccion == "derecha" and nodo_actual.derecha != null:
		nodo_actual = nodo_actual.derecha
	return nodo_actual
	
func reiniciar(): 
	nodo_actual = raiz
	
func _esta_en_nodo_seguro() -> bool:
	return nodo_actual.es_seguro
	
func es_hoja(nodo: NodoArbol) ->bool:
	return nodo.izquierda == null and nodo.derecha == null
	
	
