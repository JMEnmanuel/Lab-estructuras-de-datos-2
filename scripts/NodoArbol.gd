
extends Node
class_name NodoArbol
var nombre: String
var descripcion: String
var desafio: Dictionary
var es_seguro: bool
var esta_comprometido: bool
var pista: String

var izquierda: NodoArbol
var derecha: NodoArbol

func _init(p_nombre: String, p_descripcion: String, p_desafio: Dictionary):
	nombre = p_nombre
	descripcion = p_descripcion
	desafio = p_desafio
	es_seguro = false
	esta_comprometido = false
	pista = ""
	izquierda = null
	derecha = null
	
