extends Node

# ─────────────────────────────────────────────────────────────────
# GestorAudio — 
#
# Colocar archivos de audio en res://audio/ con los nombres:
#   evidencia.ogg        → tick al confirmar cada evidencia
#   caso_resuelto.ogg    → melodía al insertar un nodo en el árbol
#   nivel_completo.ogg   → sonido al pasar de nivel
#   juego_completo.ogg   → fanfare al terminar el juego
#   insertar.ogg         → clic al abrir pantalla de nivel
#
# Si algún archivo no existe, se usa el sonido procedural de respaldo.
# Formatos soportados: .ogg (recomendado), .wav, .mp3
# ─────────────────────────────────────────────────────────────────

const RUTA_AUDIO := "res://audio/"

const ARCHIVOS := {
	"evidencia":       "evidencia.ogg",
	"caso_resuelto":   "caso_resuelto.ogg",
	"nivel_completo":  "nivel_completo.ogg",
	"juego_completo":  "juego_completo.ogg",
	"insertar":        "insertar.ogg",
}

const SAMPLE_RATE := 44100.0


# ─── API PÚBLICA ─────────────────────────────────────────────────

func sonido_evidencia():
	if not _reproducir_archivo("evidencia"):
		_reproducir_notas([
			{"freq": 880.0,  "dur": 0.06, "vol": 0.3,  "tipo": "sine"},
			{"freq": 1100.0, "dur": 0.08, "vol": 0.25, "tipo": "sine"},
		], 0.0)


func sonido_caso_resuelto():
	if not _reproducir_archivo("caso_resuelto"):
		# Melodía en La armónica menor: B4 → E4 → A4 → F4
		_reproducir_notas([
			{"freq": 493.88, "dur": 0.10, "vol": 0.35, "tipo": "sine"},
			{"freq": 329.63, "dur": 0.10, "vol": 0.35, "tipo": "sine"},
			{"freq": 440.00, "dur": 0.10, "vol": 0.38, "tipo": "sine"},
			{"freq": 349.23, "dur": 0.22, "vol": 0.40, "tipo": "sine"},
		], 0.04)


func sonido_nivel_completo():
	if not _reproducir_archivo("nivel_completo"):
		# La (A4) — tónica de La menor
		_reproducir_notas([{"freq": 440.0, "dur": 0.45, "vol": 0.42, "tipo": "sine"}], 0.0)


func sonido_juego_completo():
	if not _reproducir_archivo("juego_completo"):
		# Re (D5) — nota brillante para el final
		_reproducir_notas([{"freq": 587.33, "dur": 0.70, "vol": 0.45, "tipo": "sine"}], 0.0)


func sonido_insertar():
	if not _reproducir_archivo("insertar"):
		# Mi (E4) — clic suave
		_reproducir_notas([{"freq": 329.63, "dur": 0.35, "vol": 0.38, "tipo": "sine"}], 0.0)


# ─── CARGA DE ARCHIVO ────────────────────────────────────────────

# Intenta reproducir el archivo de audio. Devuelve true si tuvo éxito.
func _reproducir_archivo(clave: String) -> bool:
	var ruta: String = RUTA_AUDIO + ARCHIVOS[clave]
	if not ResourceLoader.exists(ruta):
		return false

	var stream = load(ruta)
	if stream == null:
		return false

	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	return true


# ─── SÍNTESIS PROCEDURAL (respaldo) ──────────────────────────────

func _reproducir_notas(notas: Array, delay_entre: float):
	var tiempo_inicio := 0.0
	for nota in notas:
		var samples := _generar_samples(nota["freq"], nota["dur"], nota["vol"], nota["tipo"])
		_lanzar_player(samples, tiempo_inicio)
		tiempo_inicio += nota["dur"] + delay_entre


func _generar_samples(freq: float, duracion: float, volumen: float, tipo: String) -> PackedFloat32Array:
	var n_samples    := int(SAMPLE_RATE * duracion)
	var samples      := PackedFloat32Array()
	samples.resize(n_samples * 2)
	var fade_samples := int(SAMPLE_RATE * 0.015)

	for i in range(n_samples):
		var t     := float(i) / SAMPLE_RATE
		var phase := fmod(t * freq, 1.0)
		var raw   := 0.0
		match tipo:
			"sine":     raw = sin(phase * TAU)
			"square":   raw = 1.0 if phase < 0.5 else -1.0
			"triangle": raw = 2.0 * abs(2.0 * phase - 1.0) - 1.0
		var env := 1.0
		if i < fade_samples:
			env = float(i) / float(fade_samples)
		elif i > n_samples - fade_samples:
			env = float(n_samples - i) / float(fade_samples)
		env *= exp(-3.0 * t / duracion)
		var val := raw * volumen * env
		samples[i * 2]     = val
		samples[i * 2 + 1] = val

	return samples


func _lanzar_player(samples: PackedFloat32Array, delay: float):
	var byte_array := PackedByteArray()
	byte_array.resize(samples.size() * 2)
	for i in range(samples.size()):
		var val := int(clamp(samples[i] * 32767.0, -32768.0, 32767.0))
		byte_array[i * 2]     = val & 0xFF
		byte_array[i * 2 + 1] = (val >> 8) & 0xFF

	var stream        := AudioStreamWAV.new()
	stream.format     = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate   = int(SAMPLE_RATE)
	stream.stereo     = true
	stream.data       = byte_array

	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	player.play()
	await get_tree().create_timer(stream.get_length() + 0.1).timeout
	player.queue_free()
