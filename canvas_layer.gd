extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

signal on_transition_finished

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):

	if anim_name == "white_to_black":
		on_transition_finished.emit()
		animation_player.play("black_to_white")

	elif anim_name == "black_to_white":
		color_rect.visible = false

func transition():
	color_rect.visible = true
	animation_player.play("white_to_black")
