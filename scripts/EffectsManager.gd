extends Node

func play_vfx_at(vfx_name, pos):
	var new_fx = load("res://assets/effects/VFX.tscn").instantiate()

	get_tree().current_scene.add_child(new_fx)

	new_fx.setup(vfx_name, pos)
