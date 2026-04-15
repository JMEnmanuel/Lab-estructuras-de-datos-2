extends Node2D

@onready var lineas = $Lineas

var nodo_visual_scene = preload("res://Escenas/NodoVisual.tscn")

func dibujar_arbol():
	# Limpiar todo lo anterior
	for hijo in get_children():
		if hijo != lineas:
			hijo.queue_free()
	lineas.queue_free()
	
	# Redibujar líneas
	var nuevo_lineas = Node2D.new()
	nuevo_lineas.name = "Lineas"
	add_child(nuevo_lineas)
	lineas = nuevo_lineas
	
	# Dibujar desde la raíz
	var raiz = ArbolAVL.raiz
	if raiz != null:
		_dibujar_recursivo(raiz, 0, 0, 300)


func _dibujar_recursivo(nodo: NodoArbol, x: float, y: float, offset: float):
	# Instanciar nodo visual
	var nodo_visual = nodo_visual_scene.instantiate()
	nodo_visual.position = Vector2(x, y)
	nodo_visual.configurar(nodo)
	add_child(nodo_visual)
	
	# Hijo izquierdo
	if nodo.izquierda != null:
		_dibujar_linea(Vector2(x, y), Vector2(x - offset, y + 120))
		_dibujar_recursivo(nodo.izquierda, x - offset, y + 120, offset / 2)
	
	# Hijo derecho
	if nodo.derecha != null:
		_dibujar_linea(Vector2(x, y), Vector2(x + offset, y + 120))
		_dibujar_recursivo(nodo.derecha, x + offset, y + 120, offset / 2)


func _dibujar_linea(desde: Vector2, hasta: Vector2):
	var linea = Line2D.new()
	linea.add_point(desde)
	linea.add_point(hasta)
	linea.width = 2
	linea.default_color = Color.WHITE
	lineas.add_child(linea)
