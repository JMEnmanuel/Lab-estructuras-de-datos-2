extends Node

var raiz: NodoArbol


# ─── ALTURA Y BALANCE ───────────────────────────────────────────

func _obtener_altura(nodo: NodoArbol) -> int:
	if nodo == null:
		return 0
	return nodo.altura


func _actualizar_altura(nodo: NodoArbol):
	nodo.altura = 1 + max(_obtener_altura(nodo.izquierda), _obtener_altura(nodo.derecha))


func _obtener_balance(nodo: NodoArbol) -> int:
	if nodo == null:
		return 0
	return _obtener_altura(nodo.izquierda) - _obtener_altura(nodo.derecha)


# ─── ROTACIONES ─────────────────────────────────────────────────

func _rotar_derecha(y: NodoArbol) -> NodoArbol:
	var x = y.izquierda
	var t2 = x.derecha

	x.derecha = y
	y.izquierda = t2

	_actualizar_altura(y)
	_actualizar_altura(x)

	return x


func _rotar_izquierda(x: NodoArbol) -> NodoArbol:
	var y = x.derecha
	var t2 = y.izquierda

	y.izquierda = x
	x.derecha = t2

	_actualizar_altura(x)
	_actualizar_altura(y)

	return y


# ─── INSERCIÓN ──────────────────────────────────────────────────

func insertar(nodo: NodoArbol):
	raiz = _insertar_recursivo(raiz, nodo)


func _insertar_recursivo(actual: NodoArbol, nuevo: NodoArbol) -> NodoArbol:
	# Inserción BST normal
	if actual == null:
		return nuevo

	if nuevo.gravedad < actual.gravedad:
		actual.izquierda = _insertar_recursivo(actual.izquierda, nuevo)
	elif nuevo.gravedad > actual.gravedad:
		actual.derecha = _insertar_recursivo(actual.derecha, nuevo)
	else:
		return actual  # No se permiten duplicados

	_actualizar_altura(actual)

	var balance = _obtener_balance(actual)

	# Caso izquierda-izquierda
	if balance > 1 and nuevo.gravedad < actual.izquierda.gravedad:
		return _rotar_derecha(actual)

	# Caso derecha-derecha
	if balance < -1 and nuevo.gravedad > actual.derecha.gravedad:
		return _rotar_izquierda(actual)

	# Caso izquierda-derecha
	if balance > 1 and nuevo.gravedad > actual.izquierda.gravedad:
		actual.izquierda = _rotar_izquierda(actual.izquierda)
		return _rotar_derecha(actual)

	# Caso derecha-izquierda
	if balance < -1 and nuevo.gravedad < actual.derecha.gravedad:
		actual.derecha = _rotar_derecha(actual.derecha)
		return _rotar_izquierda(actual)

	return actual


# ─── BÚSQUEDA ───────────────────────────────────────────────────

func buscar(gravedad: int) -> NodoArbol:
	return _buscar_recursivo(raiz, gravedad)


func _buscar_recursivo(actual: NodoArbol, gravedad: int) -> NodoArbol:
	if actual == null or actual.gravedad == gravedad:
		return actual
	if gravedad < actual.gravedad:
		return _buscar_recursivo(actual.izquierda, gravedad)
	return _buscar_recursivo(actual.derecha, gravedad)


# ─── RECORRIDOS ─────────────────────────────────────────────────

# Inorden: retorna los nodos de menor a mayor gravedad
func obtener_inorden() -> Array:
	var resultado = []
	_inorden_recursivo(raiz, resultado)
	return resultado


func _inorden_recursivo(nodo: NodoArbol, resultado: Array):
	if nodo == null:
		return
	_inorden_recursivo(nodo.izquierda, resultado)
	resultado.append(nodo)
	_inorden_recursivo(nodo.derecha, resultado)


# ─── REPORTE FINAL ──────────────────────────────────────────────

func generar_reporte() -> String:
	var nodos = obtener_inorden()
	var reporte = "=== REPORTE FINAL DEL CASO ===\n\n"
	reporte += "Detective Alex ha reconstruido la línea completa de los hechos.\n\n"

	for nodo in nodos:
		reporte += "─────────────────────────────\n"
		reporte += "Caso #%d — %s\n" % [nodo.id, nodo.tipo_acoso]
		reporte += "Evidencias: %s\n" % ", ".join(nodo.evidencias)
		reporte += "Ley aplicable: %s\n" % nodo.ley
		reporte += "Pena posible: %s\n" % nodo.pena
		reporte += "\n"

	reporte += "─────────────────────────────\n"
	reporte += "Lo que comenzó como 'bromas' se convirtió en %d delitos reales.\n" % nodos.size()
	reporte += "La justicia digital ha sido restaurada."
	return reporte
