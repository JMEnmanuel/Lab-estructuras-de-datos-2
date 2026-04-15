extends Control

@onready var fondo = $TextureRect

var velocidad = Vector2(50, 50)

func _ready():
	modulate.a = 0.0
	fondo.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	fondo.stretch_mode = TextureRect.STRETCH_TILE
	fondo.size = get_viewport_rect().size * 2
	await fade_in()

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
	await tween.finished

func _process(delta):
	fondo.position -= velocidad * delta
	if fondo.position.x < -get_viewport_rect().size.x:
		fondo.position.x = 0
	if fondo.position.y < -get_viewport_rect().size.y:
		fondo.position.y = 0

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("C:/Users/Alexander/Documents/lab-1-edd-2/Lab-estructuras-de-datos-2/scripts/pruebas.gd")

func _on_oppciones_pressed() -> void:
	pass

func _on_salir_pressed() -> void:
	get_tree().quit()
