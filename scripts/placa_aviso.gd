extends Node2D

@onready var interaction_area: Area2D = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	Dialogic.start("placa_aviso")
	await Dialogic.timeline_ended
