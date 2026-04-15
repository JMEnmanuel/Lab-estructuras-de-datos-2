extends Node

# Retorna los 5 casos del juego listos para insertar en el árbol
func obtener_casos() -> Array:
	return [
		NodoArbol.new(
			1,
			"Mensajes ofensivos en redes sociales",
			["Capturas de pantalla de los mensajes", "Perfil del usuario agresor", "Registro de fechas y horas"],
			"Artículo 220 del Código Penal Colombiano — Injuria",
			"Multa o sanciones legales por afectar el buen nombre de una persona.",
			1
		),
		NodoArbol.new(
			2,
			"Publicaciones falsas y rumores virales",
			["Publicación original identificada", "Lista de cuentas que compartieron", "Testimonio de testigos digitales"],
			"Artículo 221 del Código Penal Colombiano — Calumnia",
			"Multas o sanciones por difundir acusaciones falsas que afectan la reputación.",
			2
		),
		NodoArbol.new(
			3,
			"Suplantación de identidad digital",
			["Perfil falso con foto de la víctima", "Dirección IP de creación de la cuenta", "Registro de actividad del perfil falso"],
			"Ley 1273 de 2009 — Delitos informáticos en Colombia",
			"Sanciones penales y multas dependiendo del daño causado.",
			3
		),
		NodoArbol.new(
			4,
			"Ataque coordinado de múltiples cuentas",
			["Lista de cuentas involucradas", "Patrones de comportamiento similares", "Registro de IPs coincidentes"],
			"Ley 1273 de 2009 y delitos de hostigamiento reiterado",
			"Sanciones penales y procesos judiciales según la gravedad.",
			4
		),
		NodoArbol.new(
			5,
			"Campaña sostenida de ciberacoso",
			["Línea de tiempo completa del acoso", "Identidad del agresor principal confirmada", "Conjunto completo de evidencias digitales"],
			"Artículos 220, 221 del Código Penal y Ley 1273 de 2009",
			"Proceso judicial completo con posibles penas privativas de libertad.",
			5
		)
	]
