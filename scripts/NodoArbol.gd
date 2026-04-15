
extends Node
class_name NodoArbol

var id: int
var tipo_acoso: String
var evidencias: Array
var ley: String
var pena: String
var gravedad: int

var altura: int
var izquierda: NodoArbol
var derecha: NodoArbol

func _init(p_id: int, p_tipo: String, p_evidencias: Array, p_ley: String, p_pena: String, p_gravedad: int):
	id = p_id
	tipo_acoso = p_tipo
	evidencias = p_evidencias
	ley = p_ley
	pena = p_pena
	gravedad = p_gravedad
	altura = 1
	izquierda = null
	derecha = null
