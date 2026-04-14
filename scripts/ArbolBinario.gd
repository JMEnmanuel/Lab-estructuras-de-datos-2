extends Node

# Backend principal del juego. Construye el árbol, asigna el nodo seguro
# aleatoriamente y controla la navegación del jugador

var raiz: NodoArbol
var nodo_actual: NodoArbol #Posición actual del jugador


func inicializar():
	_construir_arbol()
	ContenidoNodos.asignar_contenido(self)
	_asignar_nodo_seguro()
	_asignar_nodos_comprometidos()
	
	
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
	elegido.nombre = "Nodo Central Seguro"
	elegido.descripcion = "Núcleo protegido de la red. Desde aquí se coordina la restauración total del sistema."
	elegido.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Has llegado al núcleo de la red. Para restaurar completamente el sistema, ¿cuál es el primer paso?",
			"opciones": ["Formatear todos los servidores", "Apagar la red completa", "Reconectar todos los sistemas inmediatamente", "Verificar la integridad de cada sistema antes de reconectarlo"],
			"correcta": 3,
			"msg_fallo": "Incorrecto. Reconectar sin verificar puede reintroducir la amenaza.",
			"msg_exito": "Correcto. La verificación de integridad garantiza que los sistemas estén limpios antes de restaurar."
		}
	]
	
	
#Selecciona un desafio aleatorio del pool del nodo actual,
#sin repetir el que acaba de fallar
func _obtener_nuevo_desafio():
	var pool = nodo_actual.desafios
	#print("pool dentro de obtener nuevo desafio", pool.size())
	var disponibles = []
	for d in pool:
		if d != nodo_actual.desafio_actual:
			disponibles.append(d)
		
	print("Disponibles: ", disponibles.size())
	
	if disponibles.is_empty():
		disponibles = pool
	
	var indice = randi() % disponibles.size()
	nodo_actual.desafio_actual = disponibles[indice].duplicate()

	##print(" Indice elegido: ", indice)
	#print("Elemento elegido: ", disponibles[indice])
	#print("Desafio asignado: ", nodo_actual.desafio_actual)
	return nodo_actual.desafio_actual
	
	
#inicializa el desafio al entrar a un nodo nuevo
func iniciar_desafio() -> Dictionary:
	nodo_actual.desafio_actual = {}
	return _obtener_nuevo_desafio()
	

# Mueve al jugador solo si superó el desafío del nodo actual.
# Retorna el nodo resultante o null si el movimiento no es válido.
func moverse(direccion: String) -> NodoArbol:
	if not nodo_actual.desafio_actual.has("correcta"):
		return null  # No ha iniciado el desafío del nodo actual
	
	if direccion == "izquierda" and nodo_actual.izquierda != null:
		nodo_actual = nodo_actual.izquierda
		iniciar_desafio()
		return nodo_actual
	elif direccion == "derecha" and nodo_actual.derecha != null:
		nodo_actual = nodo_actual.derecha
		iniciar_desafio()
		return nodo_actual
	
	return null  # No hay hijo en esa dirección


#Regresa al jugador a la raiz
func reiniciar(): 
	nodo_actual = raiz
	nodo_actual.desafio_actual = {}
	
#True si encuentras el nodo seguro
func _esta_en_nodo_seguro() -> bool:
	return nodo_actual.es_seguro
	
#true si el nodo es una hoja
func es_hoja(nodo: NodoArbol) ->bool:
	return nodo.izquierda == null and nodo.derecha == null
	
	
	
func responder_desafio(indice_respuesta: int) -> bool:
	if indice_respuesta == nodo_actual.desafio_actual["correcta"]:
		return true 
	_obtener_nuevo_desafio()
	return false
	
	
func _asignar_nodos_comprometidos():
	var todos = _obtener_todos_los_nodos(raiz)
	var candidatos = []
	
	for nodo in todos:
		#print("Nodo: ", nodo.nombre, " es_seguro: ", nodo.es_seguro)
		if not nodo.es_seguro and nodo.nombre != "":
			candidatos.append(nodo)
	
	candidatos.shuffle()
	
	var cantidad = randi() % 2 + 4
	for i in range(cantidad):
		candidatos[i].esta_comprometido = true
		candidatos[i].pista = _generar_pista(candidatos[i])
	

func _generar_pista(nodo: NodoArbol) -> String:
	var hojas = _obtener_hojas(raiz)
	var nodo_seguro: NodoArbol
	for hoja in hojas:
		if hoja.es_seguro:
			nodo_seguro = hoja
			break
	return "Alerta: este nodo está comprometido. El nodo Central Seguro se encuentra en: "+ nodo_seguro.nombre
