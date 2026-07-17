extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

var skipped := false

func _ready():
	video_stream_player.play()

	await video_stream_player.finished

	change_to_world()


func _input(event):

	if event.is_action_pressed("skip"):
		change_to_world()


func change_to_world():

	if skipped:
		return

	skipped = true

	Transitions.transition()
	await Transitions.on_transition_finished

	get_tree().change_scene_to_file("res://world.tscn")
