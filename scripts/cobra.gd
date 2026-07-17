extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $Area2D
@onready var kill_area: Area2D = $Area2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var dead := false

func _on_area_2d_body_entered(body: Node2D) -> void:

	if dead:
		return

	if body.is_in_group("player"):

		body.take_damage()

		var dir = (body.global_position - global_position).normalized()
		body.apply_knockback(dir, 250.0, 0.15)


func _on_area_2d_2_body_entered(body: Node2D) -> void:

	if dead:
		return

	if body.is_in_group("player"):

		dead = true

		# DESATIVA AS COLISOES PRA O PLAYER NAO TOMAR DANINHO
		damage_area.monitoring = false
		damage_area.monitorable = false

		kill_area.monitoring = false
		kill_area.monitorable = false

		# QUICADA TOP
		body.bounce()

		$AudioStreamPlayer2D.play()

		animated_sprite_2d.play("die")

		await animated_sprite_2d.animation_finished
		await $AudioStreamPlayer2D.finished

		queue_free()
