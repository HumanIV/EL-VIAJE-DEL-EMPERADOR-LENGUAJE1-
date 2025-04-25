extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/mapa_chinatown.tscn")


func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://levels_menu.tscn")

func _on_exit_pressed() -> void:
	print("Boton de salir presionado")
	get_tree().quit()
