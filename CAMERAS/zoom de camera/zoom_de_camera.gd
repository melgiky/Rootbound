extends Node2D
@onready var active_cam = get_viewport().get_camera_2d()
@export_range(0, 3) var tempo_da_animacao: float = 2##Tempo que a animacao vai durar, em segundos
@export_range(0, 8) var zoom: float = 2 ##Tempo em que a animacao ficara focada no objeto
@onready var zoom_atual

func _ready() -> void:
	zoom_atual = active_cam.zoom

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name=="player":
		var anima_camera = create_tween()
		anima_camera.tween_property(active_cam,"zoom",Vector2(zoom,zoom),tempo_da_animacao)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name=="player":
		var anima_camera = create_tween()
		anima_camera.tween_property(active_cam,"zoom",zoom_atual,tempo_da_animacao)
