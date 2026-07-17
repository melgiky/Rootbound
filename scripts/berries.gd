extends StaticBody2D

@export var shine_distance := 80


@onready var player = get_tree().get_first_node_in_group("player")
@onready var shine: AudioStreamPlayer2D = $shine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var shining := false
var volume_tween: Tween

func _ready():
	point_light_2d.hide()
	shine.volume_db = -40


func _process(delta):

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= shine_distance:

		if !shining:
			shining = true

			animated_sprite_2d.play("shine")
			point_light_2d.show()

			if volume_tween:
				volume_tween.kill()

			if !shine.playing:
				shine.volume_db = -40
				shine.play()

			volume_tween = create_tween()
			volume_tween.parallel().tween_property(shine, "volume_db", 0.0, 0.4)
			volume_tween.parallel().tween_property(point_light_2d, "energy", 1.0, 0.4)

	else:

		if shining:
			shining = false

			animated_sprite_2d.play("idle")

			if volume_tween:
				volume_tween.kill()

			volume_tween = create_tween()
			volume_tween.parallel().tween_property(shine, "volume_db", -40.0, 0.4)
			volume_tween.parallel().tween_property(point_light_2d, "energy", 0.0, 0.4)

			await volume_tween.finished

			shine.stop()
			shine.volume_db = -40
			point_light_2d.hide()


func collect():

	if volume_tween:
		volume_tween.kill()

	shine.stop()
	queue_free()
