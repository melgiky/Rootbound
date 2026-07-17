extends Node2D

@onready var label2: Label = $Control/Label2
@onready var label3: Label = $Control/Label3
@onready var label1: Label = $Control/Label1


var pagina := 1

func _ready():
	label1.show()
	label2.hide()
	label3.hide()

func _input(event):

	if event.is_action_pressed("skip"): # Espaço

		match pagina:

			1:
				label1.hide()
				label2.show()
				pagina = 2

			2:
				label2.hide()
				label3.show()
				pagina = 3

			3:
				get_tree().change_scene_to_file("res://MENU/main_menu/MENU.tscn")
