extends CharacterBody2D

# ==========================================
# MOVEMENT
# ==========================================

@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0,1) var decelleration = 0.1
@export_range(0,1) var acceleration = 0.1
@export_range(-400,-200) var jump_force = -250
@export_range(0,1) var acellerate_on_jump_release = 0.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump: AudioStreamPlayer = $jump
@onready var damage: AudioStreamPlayer = $damage
@onready var game_over: AudioStreamPlayer = $game_over
@onready var collect_sound: AudioStreamPlayer = $collect_sound
@onready var world = get_parent()
@onready var game_manager: Node = $"../GameManager"
@onready var camera_2d: Camera2D = $Camera2D

var is_dead = false


# ==========================================
# HEALTH
# ==========================================

var hearts_list : Array[TextureRect]
var health = 5


# ==========================================
# MINING
# ==========================================

const MINE_INTERVAL = 0.18
var mine_timer = 0.0
var mine_direction = "right"


# ==========================================
# KNOCKBACK
# ==========================================

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0


# ==========================================
# STATES
# ==========================================

enum State { IDLE, RUN, MINE, HURT, DEAD }
var state = State.IDLE


func _ready():

	var hearts_parent = $CanvasLayer/HBoxContainer

	for child in hearts_parent.get_children():
		hearts_list.append(child)


func _physics_process(delta):

	handle_quit()
	handle_death()

	if state == State.DEAD:
		move_and_slide()
		return

	if state == State.HURT:
		handle_knockback(delta)

	else:
		handle_mining(delta)

		# só move se NÃO estiver minerando
		if state != State.MINE:
			handle_movement(delta)

	update_animation()
	move_and_slide()
	update_camera()

# ==========================================
# BASIC
# ==========================================

func handle_quit():

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func handle_death():

	if health <= 0 and not is_dead:
		is_dead = true
		state = State.DEAD
		die()


func die():

	velocity = Vector2.ZERO
	game_over.play()

	animated_sprite.play("morrer")

	await animated_sprite.animation_finished
	await get_tree().create_timer(2.0).timeout
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://MENU/death_menu/game_over.tscn")



# ==========================================
# KNOCKBACK
# ==========================================

func apply_knockback(direction: Vector2, force: float, duration: float):

	state = State.HURT

	knockback_velocity = direction * force
	knockback_velocity.y = -120

	knockback_timer = duration


func handle_knockback(delta):

	velocity = knockback_velocity

	velocity.y += gravity * delta

	knockback_timer -= delta

	if knockback_timer <= 0:

		knockback_velocity = Vector2.ZERO
		state = State.IDLE


# ==========================================
# MINING
# ==========================================

func handle_mining(delta):

	if state == State.HURT or state == State.DEAD:
		return

	if Input.is_action_pressed("LEFT_MOUSE"):

		state = State.MINE
		velocity.x = 0

		mine_timer += delta

		if mine_timer >= MINE_INTERVAL:

			mine()
			mine_timer = 0.0

	else:

		if state == State.MINE:
			state = State.IDLE

		mine_timer = 0.0
	
	if not is_on_floor():
		velocity.y += gravity * delta

func mine():

	var mouse_pos = get_global_mouse_position()

	mine_direction = get_mine_direction()

	if mine_direction == "left":
		animated_sprite.flip_h = true

	if mine_direction == "right":
		animated_sprite.flip_h = false

	world.damage_block(mouse_pos)
	



func get_mine_direction():

	var dir = get_global_mouse_position() - global_position

	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"

	return "down" if dir.y > 0 else "up"


# ==========================================
# MOVEMENT
# ==========================================

func handle_movement(delta):

	if state == State.DEAD:
		return

	if state == State.HURT:
		return

	if state == State.MINE:
		return


	if not is_on_floor():
		velocity.y += gravity * delta


	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		jump.play()


	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= acellerate_on_jump_release


	var speed = run_speed if Input.is_action_pressed("run") else walk_speed
	var direction := Input.get_axis("left","right")

	
	if direction:

		state = State.RUN

		velocity.x = move_toward(
			velocity.x,
			direction * speed,
			speed * acceleration
		)

		animated_sprite.flip_h = direction == -1

	else:

		state = State.IDLE

		velocity.x = move_toward(
			velocity.x,
			0,
			walk_speed * decelleration
		)
# ==========================================
# ANIMATION
# ==========================================

func update_animation():

	match state:

		State.IDLE:

			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")


		State.RUN:

			if animated_sprite.animation != "run":
				animated_sprite.play("run")


		State.MINE:

			match mine_direction:

				"down":

					if animated_sprite.animation != "cavar_baixo":
						animated_sprite.play("cavar_baixo")

				"up":

					if animated_sprite.animation != "cavar_cima":
						animated_sprite.play("cavar_cima")

				"left", "right":

					if animated_sprite.animation != "cavar":
						animated_sprite.play("cavar")


		State.HURT:

			if animated_sprite.animation != "dano":
				animated_sprite.play("dano")


		State.DEAD:

			if animated_sprite.animation != "morrer":
				animated_sprite.play("morrer")


# ==========================================
# DAMAGE
# ==========================================

func take_damage():

	if is_dead:
		return

	if health <= 0:
		return

	health -= 1
	damage.play()

	update_heart_display()


func update_heart_display():

	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health

	var heart_anim = hearts_list[0].get_child(0)

	if health == 1:
		heart_anim.play("beating")

	elif health > 1:
		heart_anim.play("idle")




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("collectable"):
		collect_sound.play()
		game_manager.add_fruits()
		body.collect()
		
func update_camera():

	if is_on_floor() \
	and abs(velocity.x) < 1 \
	and Input.is_action_pressed("down"):

		camera_2d.look_down()

	else:
		camera_2d.look_normal()

func bounce(force := 300.0):

	velocity.y = -force
