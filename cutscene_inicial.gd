extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	video_stream_player.play()

	await video_stream_player.finished
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://world.tscn")
