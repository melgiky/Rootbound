extends CharacterBody2D

@export var walk_speed = 150.0
const JUMP_VELOCITY = -400.0
@export_range(0,1) var decelleration = 0.1
@export_range(0,1) var acceleration = 0.1
@export_range(150,300) var run_speed = 250.0
@export_range(-200,-400) var jump_force = -250
@export_range(0,1) var acellerate_on_jump_release = 0.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var heartanimations: AnimatedSprite2D = $Heartanimations
@onready var jump: AudioStreamPlayer = $jump
@onready var world = get_parent()

var alive : bool = true
var hearts_list : Array[TextureRect]
var health = 5

func _ready() -> void:
	var hearts_parent = $CanvasLayer/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print (hearts_list)

func take_damage():
	if health >0:
		health -= 1
		animated_sprite.play("dano")
		update_heart_display()

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health

	# pega o sprite do primeiro coração
	var heart_anim = hearts_list[0].get_child(0)

	if health == 1:
		heart_anim.play("beating")
	elif health > 1:
		heart_anim.play("idle")
const TILE_SIZE = 16

# 💥 STATE MACHINE
enum State { IDLE, RUN, MINE }
var state = State.IDLE




func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if health == 0:
		get_tree().change_scene_to_file("res://MENU/MENU.tscn")

	if Input.is_action_just_pressed("LEFT_MOUSE"):
		mine()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		jump.play()

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= acellerate_on_jump_release

	# Speed
	var speed = run_speed if Input.is_action_pressed("run") else walk_speed

	var direction := Input.get_axis("left", "right")

	# 🚫 não mexe na animação se estiver minerando
	if state != State.MINE:

		if direction:
			state = State.RUN
			velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
			animated_sprite.flip_h = direction == -1
		else:
			state = State.IDLE
			velocity.x = move_toward(velocity.x, 0, walk_speed * decelleration)

	update_animation()

	move_and_slide()


# 🎞️ CENTRALIZA TODAS AS ANIMAÇÕES
func update_animation():

	match state:

		State.IDLE:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

		State.RUN:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")

		State.MINE:
			pass


# 🧭 DIREÇÃO DO MINERAR
func get_mine_direction() -> String:

	var dir = get_global_mouse_position() - global_position

	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"


# ⛏️ MINERAÇÃO
func mine():

	if state == State.MINE:
		return

	state = State.MINE
	velocity.x = 0
	var direction = get_mine_direction()
	var tile_pos = Vector2()

	match direction:

		"up":
			tile_pos = global_position + Vector2(0, -TILE_SIZE)
			animated_sprite.play("cavar")

		"down":
			tile_pos = global_position + Vector2(0, TILE_SIZE)
			animated_sprite.play("cavar")

		"right":
			tile_pos = global_position + Vector2(TILE_SIZE, 0)
			animated_sprite.play("cavar")
			animated_sprite.flip_h = false

		"left":
			tile_pos = global_position + Vector2(-TILE_SIZE, 0)
			animated_sprite.play("cavar")
			animated_sprite.flip_h = true

	world.damage_block(tile_pos)

	await animated_sprite.animation_finished

	state = State.IDLE
