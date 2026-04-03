extends Node

# Backend principal del juego. Construye el árbol, asigna el nodo seguro
# aleatoriamente y controla la navegación del jugador

var raiz: NodoArbol
var nodo_actual: NodoArbol #Posición actual del jugador


func _init():
	_construir_arbol()
	##ContenidoNodos.asignar_contenido(self)
	_asignar_nodo_seguro()
	
	
# Construye la estructura fija de 4 niveles y 15 nodos.
#                     raiz
#                   /      \
#                izq        der
#               /   \      /   \
#             izq   der  izq   der
#            / \   / \   / \   / \
#           n  n  n  n  n  n  n  n
func _construir_arbol():
	raiz = NodoArbol.new("","", [])
	
	raiz.izquierda = NodoArbol.new("","", [])
	raiz.derecha = NodoArbol.new("","", [])
	
	raiz.izquierda.izquierda = NodoArbol.new("","", [])
	raiz.izquierda.derecha = NodoArbol.new("","", [])
	raiz.derecha.izquierda = NodoArbol.new("","", [])
	raiz.derecha.derecha = NodoArbol.new("","", [])
	
	raiz.izquierda.izquierda.izquierda = NodoArbol.new("", "", [])
	raiz.izquierda.izquierda.derecha   = NodoArbol.new("", "", [])
	raiz.izquierda.derecha.izquierda   = NodoArbol.new("", "", [])
	raiz.izquierda.derecha.derecha     = NodoArbol.new("", "", [])
	raiz.derecha.izquierda.izquierda   = NodoArbol.new("", "", [])
	raiz.derecha.izquierda.derecha     = NodoArbol.new("", "", [])
	raiz.derecha.derecha.izquierda     = NodoArbol.new("", "", [])
	raiz.derecha.derecha.derecha       = NodoArbol.new("", "", [])
	
	
	nodo_actual = raiz
	
	
#Retorna todos los nodos del arbol en un array
func _obtener_todos_los_nodos(nodo: NodoArbol) -> Array:
	if nodo == null:
		return[]
	return [nodo] + _obtener_todos_los_nodos(nodo.izquierda)\
				  + _obtener_todos_los_nodos(nodo.derecha)

#retorna solo las hojas del arbol(siendo estas elegibles para ser el nodo seguro
func _obtener_hojas(nodo: NodoArbol) -> Array:
	if nodo == null:
		return []
	if nodo.izquierda == null and nodo.derecha == null:
		return [nodo]
	return _obtener_hojas(nodo.izquierda) + _obtener_hojas(nodo.derecha)

#Elige una hoja al azar como nodo seguro
func _asignar_nodo_seguro():
	var hojas = _obtener_hojas(raiz)
	var elegido = hojas[randi() % hojas.size()]
	elegido.es_seguro = true
	
	
#Selecciona un desafio aleatorio del pool del nodo actual,
#sin repetir el que acaba de fallar
func _obtener_nuevo_desafio():
	var pool = nodo_actual.desafios
	var disponibles = []
	for d in pool:
		if d != nodo_actual.desafio_actual:
			disponibles.append(d)
		
	if disponibles.is_empty():
		disponibles = pool
	nodo_actual.desafio_actual = disponibles[randi() % disponibles.size()]
	return nodo_actual.desafio_actual
	
	
#inicializa el desafio al entrar a un nodo nuevo
func iniciar_desafio() -> Dictionary:
	nodo_actual.desafio_actual = {}
	return _obtener_nuevo_desafio()
	

#Mueve al jugador entre derecha e izquierda, si no hay hijo en esa dirección no se mueve
func _moverse(direccion: String) -> NodoArbol:
	if direccion == "izquierda" and nodo_actual.izquierda != null:
		nodo_actual = nodo_actual.izquierda
	elif direccion == "derecha" and nodo_actual.derecha != null:
		nodo_actual = nodo_actual.derecha
	return nodo_actual


#Regresa al jugador a la raiz
func reiniciar(): 
	nodo_actual = raiz
	
#True si encuentras el nodo seguro
func _esta_en_nodo_seguro() -> bool:
	return nodo_actual.es_seguro
	
#true si el nodo es una hoja
func es_hoja(nodo: NodoArbol) ->bool:
	return nodo.izquierda == null and nodo.derecha == null
	
	
