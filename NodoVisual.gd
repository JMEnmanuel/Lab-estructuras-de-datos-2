extends Control
@onready var label = $Panel/Label

func configurar(nodo: NodoArbol):
	label.text = "Caso #%d\nGravedad: %d" % [nodo.id, nodo.gravedad]
	
