extends Sala

@onready var animated_sprite_2d_3: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D3

func _ready() -> void:
	animated_sprite_2d_3.play("default")
