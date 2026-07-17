extends Node
@onready var fruits: Control = $"../CanvasLayer2/Control/HBoxContainer/Fruits/Label"

@onready var level_timer: Timer = $"../LevelTimer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fruits.text = str(Gamestate.fruits)
func add_fruits():
	Gamestate.fruits+=1
	fruits.text = str(Gamestate.fruits)
