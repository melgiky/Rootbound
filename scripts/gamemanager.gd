extends Node
@onready var fruits: Control = $"../CanvasLayer2/Control/HBoxContainer/Fruits/Label"
@onready var timer = $"../CanvasLayer2/Control/HBoxContainer/timer/Label"
@onready var level_timer = $"../level_timer"


func game_over():
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://MENU/death_menu/game_over.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fruits.text = str(Gamestate.fruits)
	timer.text = str(int(level_timer.time_left),"s")
func add_fruits():
	Gamestate.fruits+=1
	fruits.text = str(Gamestate.fruits)
	
func _process(delta: float) -> void:
	timer.text = str(int(level_timer.time_left),"s")
