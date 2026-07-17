extends Node2D

@export var speed = 160.0
var current_speed = 0.0

func _physics_process(delta):
	position.y += current_speed * delta


func _on_player_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$AnimationPlayer.play("Shake")
		$AudioStreamPlayer2D.play()

		stop_audio_after_1_second()

		await $AnimationPlayer.animation_finished
		fall()

func stop_audio_after_1_second():
	await get_tree().create_timer(1.0).timeout
	$AudioStreamPlayer2D.stop()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()

		var dir = (
			body.global_position - global_position
		).normalized()

		body.apply_knockback(dir, 250.0, 0.15)
		
func fall():
	current_speed = speed
	await get_tree().create_timer(5).timeout
	queue_free()
