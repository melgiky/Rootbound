extends Node2D

@onready var target_camera: Camera2D = $Camera2D
@onready var active_cam: Camera2D = $"../Player/Camera2D"
@onready var player: CharacterBody2D = $"../Player"

@export var alvo: Node2D

@export var tempo_movimento := 0.7
@export var tempo_foco := 0.4
@export var tempo_zoom := 0.35

# Quanto menor, mais distante fica a câmera
@export var zoom_out := Vector2(1.7, 1.7)

var visto := false
var zoom_original: Vector2


func _ready():
	target_camera.enabled = false


func freeze_player(freeze: bool):
	player.set_physics_process(!freeze)
	player.set_process_input(!freeze)
	player.set_process_unhandled_input(!freeze)


func finalizar():
	freeze_player(false)

	target_camera.enabled = false
	active_cam.enabled = true
	active_cam.make_current()


func _on_body_shape_entered(_rid, body, _body_shape, _local_shape):

	if visto or body != player:
		return

	visto = true

	zoom_original = active_cam.zoom

	target_camera.global_position = active_cam.global_position
	target_camera.rotation = active_cam.rotation
	target_camera.zoom = zoom_original

	target_camera.enabled = true
	target_camera.make_current()

	freeze_player(true)

	var tween = create_tween()

	# Vai até o objetivo dando zoom out
	tween.parallel().tween_property(
		target_camera,
		"global_position",
		alvo.global_position,
		tempo_movimento
	)

	tween.parallel().tween_property(
		target_camera,
		"zoom",
		zoom_out,
		tempo_zoom
	)

	# Mostra rapidamente o objetivo
	tween.tween_interval(tempo_foco)

	# Volta para o player mantendo o zoom out
	tween.tween_property(
		target_camera,
		"global_position",
		active_cam.global_position,
		tempo_movimento
	)

	# Só depois faz o zoom voltar
	tween.tween_property(
		target_camera,
		"zoom",
		zoom_original,
		tempo_zoom
	)

	tween.tween_callback(finalizar)
