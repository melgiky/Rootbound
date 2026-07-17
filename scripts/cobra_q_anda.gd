extends CharacterBody2D

@export var speed := 50.0

var direction := -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $Area2D
@onready var kill_area: Area2D = $Area2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var colisao_chao: CollisionShape2D = $colisao_chao

var dead := false


func _physics_process(delta):

	# Quando morreu, não anda mais
	if dead:
		return

	# Gravidade
	if !is_on_floor():
		velocity.y += gravity * delta

	# Movimento
	velocity.x = direction * speed

	move_and_slide()

	# Vira ao bater na parede
	if is_on_wall():

		var collision = get_last_slide_collision()

		if collision:

			var collider = collision.get_collider()

			# Ignora o player
			if collider.is_in_group("player"):
				return

			direction *= -1
			animated_sprite_2d.flip_h = direction > 0


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

		# Para completamente o movimento
		velocity = Vector2.ZERO

		# Desliga as áreas
		damage_area.monitoring = false
		damage_area.monitorable = false

		kill_area.monitoring = false
		kill_area.monitorable = false

		# Desliga a colisão do corpo
		colisao_chao.set_deferred("disabled", true)

		# Quicada
		body.bounce()

		audio_stream_player_2d.play()

		animated_sprite_2d.play("die")

		# Mantém o sprite parado olhando para a direção atual
		animated_sprite_2d.pause()

		# Espera um frame para garantir que o primeiro frame da animação seja aplicado
		await get_tree().process_frame
		velocity = Vector2.ZERO
		set_physics_process(false)
		animated_sprite_2d.play("die")

		await animated_sprite_2d.animation_finished
		await audio_stream_player_2d.finished

		queue_free()
