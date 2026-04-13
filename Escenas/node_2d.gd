extends Node2D
func _ready():
	#Verificar que el contenido se asignó correctamente
	ArbolBinario.inicializar()
	print("Pool size: ", ArbolBinario.nodo_actual.desafios.size())
	var desafio = ArbolBinario.iniciar_desafio()
	print("Desafio: ", desafio)
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

	print("tamaño del pool: ", ArbolBinario.nodo_actual.desafios.size())
	print("Desafío completo: ", desafio)
	print("Desafio: ", desafio["pregunta"])
	print("Opciones: ", desafio["opciones"])
	print("Indice correcto: ", desafio["correcta"])
	
	#Probar respuesta incorrecta
	var respuesta_incorrecta = (desafio["correcta"]+1)%4
	print("Respondiendo incorrectamente (indice ", respuesta_incorrecta," )")
	var resultado = ArbolBinario.responder_desafio(respuesta_incorrecta)
	print("Resultado, ", resultado)
	
	var todos = ArbolBinario._obtener_todos_los_nodos(ArbolBinario.raiz)
	for nodo in todos:
		if nodo.esta_comprometido:
			print("Comprometido: ", nodo.nombre)
			
	
