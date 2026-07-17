extends Camera2D

@export var look_down_distance := 64.0
@export var camera_speed := 8.0

var target_offset := Vector2.ZERO

func _process(delta):
	offset = offset.lerp(target_offset, camera_speed * delta)

func look_down():
	target_offset.y = look_down_distance

func look_normal():
	target_offset.y = 0
