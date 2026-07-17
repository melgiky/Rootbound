extends Node2D

func _on_button_pressed() -> void:
	Gamestate.reset()
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://world.tscn")
