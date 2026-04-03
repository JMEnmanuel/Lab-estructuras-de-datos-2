extends Node2D
func _ready():
	#Verificar que el contenido se asignó correctamente
	print("Debug")
	print("Raiz: ", ArbolBinario.raiz.nombre)
	print("izquierda: ", ArbolBinario.raiz.izquierda.nombre)
	print("derecha: ", ArbolBinario.raiz.derecha.nombre)
	#Verificar que el nodo seguro fue asignado:
	var hojas = ArbolBinario._obtener_hojas(ArbolBinario.raiz)
	for hoja in hojas:
		if hoja.es_seguro:
			print("nodo seguro está en: ", hoja.nombre)
			
			
	#Verificar un desafio 
	var desafio = ArbolBinario.iniciar_desafio()
	print("Desafio en raiz: ", desafio["pregunta"])
