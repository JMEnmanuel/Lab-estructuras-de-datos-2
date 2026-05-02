extends Node

# ─── SEÑALES ────────────────────────────────────────────────────
# tipo: "LL", "RR", "LR", "RL"
# ids:  array con los ids de los nodos involucrados en la rotación
signal rotacion_ocurrida(tipo: String, ids: Array)

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
	var x  = y.izquierda
	var t2 = x.derecha

	x.derecha  = y
	y.izquierda = t2

	_actualizar_altura(y)
	_actualizar_altura(x)

	return x


func _rotar_izquierda(x: NodoArbol) -> NodoArbol:
	var y  = x.derecha
	var t2 = y.izquierda

	y.izquierda = x
	x.derecha   = t2

	_actualizar_altura(x)
	_actualizar_altura(y)

	return y


# ─── INSERCIÓN ──────────────────────────────────────────────────

func insertar(nodo: NodoArbol):
	raiz = _insertar_recursivo(raiz, nodo)


func _insertar_recursivo(actual: NodoArbol, nuevo: NodoArbol) -> NodoArbol:
	if actual == null:
		return nuevo

	if nuevo.gravedad < actual.gravedad:
		actual.izquierda = _insertar_recursivo(actual.izquierda, nuevo)
	elif nuevo.gravedad > actual.gravedad:
		actual.derecha = _insertar_recursivo(actual.derecha, nuevo)
	else:
		return actual

	_actualizar_altura(actual)

	var balance = _obtener_balance(actual)

	# Caso izquierda-izquierda (LL)
	if balance > 1 and _obtener_balance(actual.izquierda) >= 0:
		var ids = [actual.id, actual.izquierda.id]
		var resultado = _rotar_derecha(actual)
		rotacion_ocurrida.emit("LL", ids)
		return resultado

	# Caso derecha-derecha (RR)
	if balance < -1 and _obtener_balance(actual.derecha) <= 0:
		var ids = [actual.id, actual.derecha.id]
		var resultado = _rotar_izquierda(actual)
		rotacion_ocurrida.emit("RR", ids)
		return resultado

	# Caso izquierda-derecha (LR)
	if balance > 1 and _obtener_balance(actual.izquierda) < 0:
		var ids = [actual.id, actual.izquierda.id, actual.izquierda.derecha.id]
		actual.izquierda = _rotar_izquierda(actual.izquierda)
		var resultado = _rotar_derecha(actual)
		rotacion_ocurrida.emit("LR", ids)
		return resultado

	# Caso derecha-izquierda (RL)
	if balance < -1 and _obtener_balance(actual.derecha) > 0:
		var ids = [actual.id, actual.derecha.id, actual.derecha.izquierda.id]
		actual.derecha = _rotar_derecha(actual.derecha)
		var resultado = _rotar_izquierda(actual)
		rotacion_ocurrida.emit("RL", ids)
		return resultado

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


# ─── UTILIDADES ─────────────────────────────────────────────────

func obtener_altura_arbol() -> int:
	return _obtener_altura(raiz)


func obtener_balance_raiz() -> int:
	return _obtener_balance(raiz)


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
