extends Node

func asignar_contenido(arbol):
	var r = arbol.raiz

	# ─── NIVEL 1 ────────────────────────────────────────────────────────
	r.nombre = "Gateway Principal"
	r.descripcion = "Punto de entrada a toda la red corporativa. El tráfico entrante y saliente pasa por aquí."
	r.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "El sistema detecta un volumen inusual de solicitudes entrantes que está saturando el Gateway. ¿Qué acción tomas?",
			"opciones": ["Ignorar, puede ser tráfico normal", "Apagar el Gateway temporalmente", "Activar limitación de tasa y alertar al equipo", "Redirigir todo el tráfico al servidor interno"],
			"correcta": 2,
			"msg_fallo": "Incorrecto. Ignorar o apagar el Gateway expone la red.",
			"msg_exito": "Correcto. Limitar la tasa detiene el ataque DDoS sin cortar el servicio."
		},
		{
			"tipo": "verdadero_falso",
			"pregunta": "Un ataque DDoS busca robar información confidencial de la red.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Un DDoS busca saturar el servicio, no robar datos.",
			"msg_exito": "Correcto. El objetivo del DDoS es interrumpir el servicio, no robar datos."
		},
		{
			"tipo": "multiple",
			"pregunta": "Detectas que el Gateway está enviando datos hacia una IP desconocida en otro país. ¿Qué haces?",
			"opciones": ["Bloquear la IP y analizar el tráfico saliente", "Asumir que es una actualización automática", "Aumentar el ancho de banda", "Reiniciar el Gateway"],
			"correcta": 0,
			"msg_fallo": "Incorrecto. El tráfico saliente no autorizado puede indicar una filtración de datos.",
			"msg_exito": "Correcto. Bloquear y analizar es la respuesta adecuada ante tráfico sospechoso."
		}
	]

	# ─── NIVEL 2 ────────────────────────────────────────────────────────
	r.izquierda.nombre = "Firewall Perimetral"
	r.izquierda.descripcion = "Primera línea de defensa. Filtra el tráfico entre la red interna y el exterior."
	r.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "El firewall está bloqueando tráfico legítimo de clientes. Un colega sugiere desactivarlo temporalmente. ¿Qué haces?",
			"opciones": ["Desactivarlo, el cliente es prioridad", "Ignorar el problema", "Reemplazar el firewall por uno nuevo", "Revisar y ajustar las reglas sin desactivarlo"],
			"correcta": 3,
			"msg_fallo": "Incorrecto. Desactivar el firewall deja la red completamente expuesta.",
			"msg_exito": "Correcto. Las reglas deben ajustarse sin comprometer la protección."
		},
		{
			"tipo": "verdadero_falso",
			"pregunta": "Un firewall correctamente configurado puede detener el 100% de los ataques cibernéticos.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Ningún firewall garantiza protección total por sí solo.",
			"msg_exito": "Correcto. El firewall es una capa de defensa, no una solución completa."
		}
	]

	r.derecha.nombre = "Servidor DNS"
	r.derecha.descripcion = "Traduce nombres de dominio a direcciones IP. Objetivo frecuente de ataques de envenenamiento."
	r.derecha.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Los usuarios reportan que al escribir la URL del banco son redirigidos a una página falsa. ¿Qué tipo de ataque es?",
			"opciones": ["Fuerza bruta", "DDoS", "Ransomware", "DNS Spoofing"],
			"correcta": 3,
			"msg_fallo": "Incorrecto. Este comportamiento es característico del DNS Spoofing.",
			"msg_exito": "Correcto. El DNS Spoofing manipula las respuestas del servidor para redirigir usuarios."
		},
		{
			"tipo": "multiple",
			"pregunta": "Para proteger el servidor DNS de manipulaciones externas, ¿qué medida implementas?",
			"opciones": ["Bloquear todo el tráfico UDP", "Implementar DNSSEC para validar respuestas", "Cambiar la contraseña del servidor", "Desactivar el DNS"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. DNSSEC es el estándar para autenticar respuestas DNS.",
			"msg_exito": "Correcto. DNSSEC garantiza la integridad de las respuestas del servidor DNS."
		}
	]

	# ─── NIVEL 3 ────────────────────────────────────────────────────────
	r.izquierda.izquierda.nombre = "Servidor de Correo"
	r.izquierda.izquierda.descripcion = "Gestiona las comunicaciones internas y externas de la empresa."
	r.izquierda.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Recibes un correo del CEO pidiendo transferir fondos urgentemente a una cuenta externa. ¿Qué haces?",
			"opciones": ["Reenviar el correo a todos", "Transferir inmediatamente", "Verificar la solicitud por otro canal de comunicación", "Ignorar el correo"],
			"correcta": 2,
			"msg_fallo": "Incorrecto. Este es un ataque de phishing dirigido conocido como BEC.",
			"msg_exito": "Correcto. Siempre se deben verificar solicitudes sensibles por un canal alternativo."
		},
		{
			"tipo": "verdadero_falso",
			"pregunta": "El cifrado de correos electrónicos garantiza que no puedan ser interceptados por atacantes.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. El cifrado reduce el riesgo pero no garantiza protección total.",
			"msg_exito": "Correcto. El cifrado es una capa de protección, no una garantía absoluta."
		}
	]

	r.izquierda.derecha.nombre = "Servidor de Archivos"
	r.izquierda.derecha.descripcion = "Almacena documentos críticos de la empresa. Objetivo principal de ransomware."
	r.izquierda.derecha.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Los archivos del servidor están siendo cifrados y aparece un mensaje pidiendo rescate. ¿Qué haces?",
			"opciones": ["Formatear todo sin respaldar", "Desconectar el servidor, activar respaldos y reportar el incidente", "Esperar a que termine el cifrado", "Pagar el rescate inmediatamente"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Pagar no garantiza recuperar los archivos y financia a los atacantes.",
			"msg_exito": "Correcto. Aislar, restaurar desde respaldo y reportar es el protocolo correcto."
		},
		{
			"tipo": "verdadero_falso",
			"pregunta": "Pagar el rescate en un ataque de ransomware garantiza recuperar los archivos cifrados.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Pagar no garantiza nada y financia futuros ataques.",
			"msg_exito": "Correcto. Pagar no garantiza la recuperación y alienta a los atacantes."
		}
	]

	r.derecha.izquierda.nombre = "Servidor de Autenticación"
	r.derecha.izquierda.descripcion = "Gestiona el acceso de usuarios a los sistemas. Punto crítico de control de identidad."
	r.derecha.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Una cuenta administrativa inició sesión a las 3am desde un país extranjero. ¿Qué haces?",
			"opciones": ["Ignorarlo, puede ser el administrador viajando", "Esperar a que el administrador reporte algo", "Suspender la sesión, bloquear la cuenta y notificar al administrador", "Cambiar la contraseña al día siguiente"],
			"correcta": 2,
			"msg_fallo": "Incorrecto. Los accesos fuera de horario desde ubicaciones inusuales son señales de alerta crítica.",
			"msg_exito": "Correcto. Suspender y notificar de inmediato es la respuesta correcta ante accesos sospechosos."
		},
		{
			"tipo": "multiple",
			"pregunta": "Para fortalecer el servidor de autenticación, ¿qué medida implementas primero?",
			"opciones": ["Implementar autenticación multifactor", "Permitir contraseñas de 4 caracteres para mayor facilidad", "Desactivar el bloqueo de cuentas", "Eliminar contraseñas y usar solo nombre de usuario"],
			"correcta": 0,
			"msg_fallo": "Incorrecto. Sin MFA las credenciales comprometidas dan acceso total.",
			"msg_exito": "Correcto. El MFA añade una capa adicional que protege incluso si la contraseña es robada."
		}
	]

	r.derecha.derecha.nombre = "Base de Datos Principal"
	r.derecha.derecha.descripcion = "Contiene información sensible de clientes y operaciones. Objetivo de ataques de inyección."
	r.derecha.derecha.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Un formulario web permite ingresar texto libre que se ejecuta directamente en la base de datos. ¿Qué vulnerabilidad representa?",
			"opciones": ["DDoS", "Phishing", "SQL Injection", "XSS"],
			"correcta": 2,
			"msg_fallo": "Incorrecto. La ejecución de código en la base de datos es SQL Injection.",
			"msg_exito": "Correcto. SQL Injection permite manipular consultas directamente en la base de datos."
		},
		{
			"tipo": "verdadero_falso",
			"pregunta": "Ocultar el nombre de la base de datos es suficiente para protegerla de ataques de inyección.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. La seguridad por oscuridad no es una protección real.",
			"msg_exito": "Correcto. Se necesitan consultas parametrizadas, no solo ocultar información."
		}
	]

	# ─── NIVEL 4 (HOJAS) ────────────────────────────────────────────────
	r.izquierda.izquierda.izquierda.nombre = "Terminal de Empleado A"
	r.izquierda.izquierda.izquierda.descripcion = "Estación de trabajo del área de finanzas. Acceso a sistemas de pago."
	r.izquierda.izquierda.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Un empleado descarga un archivo adjunto de un correo no esperado y el antivirus lanza una alerta. ¿Qué haces?",
			"opciones": ["Desinstalar el antivirus", "Reiniciar la computadora", "Ignorar la alerta y abrir el archivo", "Aislar la terminal y reportar el incidente a seguridad"],
			"correcta": 3,
			"msg_fallo": "Incorrecto. Ignorar alertas del antivirus puede resultar en una infección total.",
			"msg_exito": "Correcto. Aislar la terminal evita que una posible amenaza se propague a la red."
		}
	]

	r.izquierda.izquierda.derecha.nombre = "Terminal de Empleado B"
	r.izquierda.izquierda.derecha.descripcion = "Estación de trabajo del área de recursos humanos. Acceso a datos personales."
	r.izquierda.izquierda.derecha.desafios = [
		{
			"tipo": "verdadero_falso",
			"pregunta": "El soporte técnico legítimo puede solicitar tu contraseña para resolver problemas en tu cuenta.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Ningún soporte técnico legítimo solicita contraseñas.",
			"msg_exito": "Correcto. Solicitar contraseñas es siempre una señal de ingeniería social."
		}
	]

	r.izquierda.derecha.izquierda.nombre = "Módulo de Respaldo"
	r.izquierda.derecha.izquierda.descripcion = "Sistema encargado de realizar copias de seguridad periódicas de todos los datos críticos."
	r.izquierda.derecha.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "El módulo de respaldo lleva 3 semanas sin ejecutarse por un error silencioso. ¿Qué política implementas?",
			"opciones": ["Hacer respaldos manuales ocasionalmente", "Implementar monitoreo y alertas automáticas sobre el estado del respaldo", "Eliminar el módulo y usar USBs", "Esperar a que alguien lo note"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Sin monitoreo los fallos en los respaldos pueden pasar desapercibidos.",
			"msg_exito": "Correcto. El monitoreo automatizado garantiza que los respaldos se ejecuten correctamente."
		}
	]

	r.izquierda.derecha.derecha.nombre = "Sistema de Monitoreo"
	r.izquierda.derecha.derecha.descripcion = "Supervisa el estado de toda la red en tiempo real. Detecta anomalías y genera alertas."
	r.izquierda.derecha.derecha.desafios = [
		{
			"tipo": "verdadero_falso",
			"pregunta": "La fatiga de alertas ocurre cuando los analistas reciben tantas alertas falsas que empiezan a ignorarlas todas.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 0,
			"msg_fallo": "Incorrecto. La fatiga de alertas es un problema real y documentado en ciberseguridad.",
			"msg_exito": "Correcto. La fatiga de alertas es una de las principales causas de brechas no detectadas."
		}
	]

	r.derecha.izquierda.izquierda.nombre = "Servidor VPN"
	r.derecha.izquierda.izquierda.descripcion = "Permite el acceso remoto seguro a la red interna desde el exterior."
	r.derecha.izquierda.izquierda.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "Un empleado remoto se conecta a la VPN desde una red WiFi pública. ¿Cuál es el riesgo principal?",
			"opciones": ["Que la conexión sea más lenta", "Que un atacante intercepte credenciales antes de establecer la VPN", "Ninguno, la VPN cifra todo", "Que el empleado no pueda conectarse"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. El momento de establecer la conexión VPN puede ser vulnerable en redes públicas.",
			"msg_exito": "Correcto. Las redes públicas exponen el tráfico previo al cifrado de la VPN."
		}
	]

	r.derecha.izquierda.derecha.nombre = "Servidor Web"
	r.derecha.izquierda.derecha.descripcion = "Aloja el sitio web público de la empresa. Expuesto directamente a internet."
	r.derecha.izquierda.derecha.desafios = [
		{
			"tipo": "multiple",
			"pregunta": "El servidor permite que usuarios suban archivos sin validar su tipo o contenido. ¿Qué vulnerabilidad representa?",
			"opciones": ["Subida de archivos maliciosos para ejecución remota", "DNS Spoofing", "Fuerza bruta", "DDoS"],
			"correcta": 0,
			"msg_fallo": "Incorrecto. Sin validación un atacante puede subir scripts maliciosos al servidor.",
			"msg_exito": "Correcto. La subida sin validación permite ejecutar código arbitrario en el servidor."
		}
	]

	r.derecha.derecha.izquierda.nombre = "Sistema de Control Industrial"
	r.derecha.derecha.izquierda.descripcion = "Controla equipos físicos críticos de la empresa. Un ataque aquí tiene consecuencias reales."
	r.derecha.derecha.izquierda.desafios = [
		{
			"tipo": "verdadero_falso",
			"pregunta": "Conectar sistemas de control industrial directamente a internet facilita el monitoreo remoto sin riesgos significativos.",
			"opciones": ["Verdadero", "Falso"],
			"correcta": 1,
			"msg_fallo": "Incorrecto. Los sistemas industriales expuestos a internet son blancos críticos.",
			"msg_exito": "Correcto. Los sistemas industriales deben estar en redes aisladas con acceso estrictamente controlado."
		}
	]
