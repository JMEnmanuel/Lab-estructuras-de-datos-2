
extends Node
class_name NodoArbol

#Modela un servidor/dispositivo de la red dentro del arbol binario
var nombre: String #nombre del servidor
var descripcion: String #texto que se muestra al jugador al entrar al nodo
var desafios: Array #Lista de desafios de ciberseguridad del nodo
var desafio_actual: Dictionary #Desafio activo en este momento
# Estructura de cada desafío en el pool:
#   "pregunta"  : String  -> Situación narrativa presentada al jugador
#   "opciones"  : Array   -> Lista de respuestas posibles
#   "correcta"  : int     -> Índice de la respuesta correcta
#   "msg_fallo" : String  -> Mensaje al responder incorrectamente
#   "msg_exito" : String  -> Mensaje al responder correctamente


var es_seguro: bool
var esta_comprometido: bool
var pista: String #pista al entrar a un nodo comprometido

var izquierda: NodoArbol
var derecha: NodoArbol

func _init(p_nombre: String, p_descripcion: String, p_desafios: Array):
	nombre = p_nombre
	descripcion = p_descripcion
	desafios = p_desafios
	desafio_actual = {}
	es_seguro = false
	esta_comprometido = false
	pista = ""
	izquierda = null
	derecha = null
	
