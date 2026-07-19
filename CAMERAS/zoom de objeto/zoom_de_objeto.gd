extends Node2D

@onready var target_camera: Camera2D = $Camera2D
@onready var active_cam: Camera2D = $"../Player/Camera2D"
@onready var player: CharacterBody2D = $"../Player"
@onready var espaço_para_pular: Label = $espaço_para_pular

@export var alvo: Node2D

@export var tempo_movimento := 0.75
@export var tempo_foco := 0.35

# Zoom out mais rápido
@export var tempo_zoom_out := 0.22

# Zoom in mais suave
@export var tempo_zoom_in := 0.45

@export var zoom_out := Vector2(2.0, 2.0)
@export var zoom_objeto := Vector2(3.5, 3.5)

var visto := false
var zoom_original: Vector2

var tween: Tween
var mostrando_objeto := false


func _ready():
	target_camera.enabled = false
	espaço_para_pular.hide()


func freeze_player(freeze: bool):
	player.set_physics_process(!freeze)
	player.set_process_input(!freeze)
	player.set_process_unhandled_input(!freeze)


func finalizar():

	if !mostrando_objeto:
		return

	mostrando_objeto = false
	espaço_para_pular.hide()

	freeze_player(false)

	target_camera.enabled = false
	active_cam.enabled = true
	active_cam.make_current()


func _unhandled_input(event):

	if !mostrando_objeto:
		return

	if event.is_action_pressed("skip"):

		if tween:
			tween.kill()

		finalizar()


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

	mostrando_objeto = true
	espaço_para_pular.show()

	tween = create_tween()

	# Vai para o objeto
	tween.parallel().tween_property(
		target_camera,
		"global_position",
		alvo.global_position,
		tempo_movimento
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(
		target_camera,
		"zoom",
		zoom_out,
		tempo_zoom_out
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Zoom in no objeto
	tween.tween_property(
		target_camera,
		"zoom",
		zoom_objeto,
		tempo_zoom_in
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Espera
	tween.tween_interval(tempo_foco)

	# Volta para o player
	tween.parallel().tween_property(
		target_camera,
		"global_position",
		active_cam.global_position,
		tempo_movimento
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(
		target_camera,
		"zoom",
		zoom_out,
		tempo_zoom_out
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Zoom original
	tween.tween_property(
		target_camera,
		"zoom",
		zoom_original,
		tempo_zoom_in
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(finalizar)
