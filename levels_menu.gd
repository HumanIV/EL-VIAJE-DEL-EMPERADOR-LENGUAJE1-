extends Control


func _on_change_lvl_1_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/mapa_chinatown.tscn")


func _on_change_lvl_2_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/mapa_del_cielo.tscn")


func _on_change_lvl_3_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/reino_de_fuego.tscn")


func _on_change_lvl_4_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/reino_tierra.tscn")
