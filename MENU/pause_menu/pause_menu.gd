extends CanvasLayer

var paused := false

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()


func _input(event):

	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause():

	paused = !paused

	get_tree().paused = paused

	visible = paused

func _on_resume_pressed() -> void:
	paused = false

	get_tree().paused = false

	hide()

func _on_restart_pressed() -> void:
	get_tree().paused = false

	get_tree().reload_current_scene()
	

func _on_menu_pressed() -> void:

	get_tree().paused = false

	get_tree().change_scene_to_file("res://MENU/main_menu/MENU.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
