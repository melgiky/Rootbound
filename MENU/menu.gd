extends Node2D


func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()



func _on_opcoes_pressed() -> void:
	get_tree().quit()
