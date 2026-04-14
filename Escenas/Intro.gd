extends Control

func _ready():
	modulate.a = 1.0
	await get_tree().create_timer(3.0).timeout
	await fade_out()
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	await tween.finished
