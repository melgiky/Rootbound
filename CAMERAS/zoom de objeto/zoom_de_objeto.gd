extends Node2D


@onready var target_camera: Camera2D = $Camera2D
@onready var active_cam: Camera2D = $"../Player/Camera2D"
@onready var player: CharacterBody2D = $"../Player"


@export var alvo: Node2D

@export_range(0, 3) var tempo_da_animacao := 0.8
@export_range(0, 3) var atraso := 0.8

# Zoom durante a visão do objeto
@export var zoom_out := Vector2(2.5, 2.5)

# Tempo da animação do zoom
@export_range(0, 3) var tempo_zoom := 0.5


var visto := false
var zoom_original: Vector2


func _ready() -> void:
	target_camera.enabled = false


func Freeze(arg: bool):
	player.set_physics_process(arg)
	player.set_process_input(arg)
	player.set_process_unhandled_input(arg)


func UnFreeze():

	Freeze(true)

	target_camera.enabled = false

	active_cam.enabled = true
	active_cam.make_current()


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:

	if !active_cam or body.name != "Player" or visto:
		return


	visto = true


	# Guarda o zoom original da câmera do player
	zoom_original = active_cam.zoom


	# Copia a câmera do player
	target_camera.global_position = active_cam.global_position
	target_camera.rotation = active_cam.rotation
	target_camera.zoom = active_cam.zoom


	target_camera.enabled = true
	target_camera.make_current()


	Freeze(false)


	var anima_camera = create_tween()


	# Zoom out suave
	anima_camera.parallel().tween_property(
		target_camera,
		"zoom",
		zoom_out,
		tempo_zoom
	)


	# Move até o objeto
	anima_camera.parallel().tween_property(
		target_camera,
		"global_position",
		alvo.global_position,
		tempo_da_animacao
	)


	anima_camera.tween_interval(atraso)


	# Volta para o player
	anima_camera.tween_property(
		target_camera,
		"global_position",
		active_cam.global_position,
		tempo_da_animacao
	)


	# Volta o zoom original antes de devolver a câmera
	anima_camera.parallel().tween_property(
		target_camera,
		"zoom",
		zoom_original,
		tempo_zoom
	)


	anima_camera.tween_callback(UnFreeze)
