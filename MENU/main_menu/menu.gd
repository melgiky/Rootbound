extends Node2D


func _on_iniciar_pressed() -> void:
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://SCENES/cutscene_inicial.tscn")


func _on_sair_pressed() -> void:
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().quit()



func _on_opcoes_pressed() -> void:
	get_tree().quit()
	
