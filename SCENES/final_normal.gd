extends Node2D

func _input(event):
	if event.is_action_pressed("skip"):
		Transitions.transition()
		Transitions.on_transition_finished
		get_tree().change_scene_to_file("res://MENU/main_menu/MENU.tscn")
