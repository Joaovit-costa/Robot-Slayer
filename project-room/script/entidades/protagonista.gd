extends CharacterBody2D
class_name protagonista


@export var vitalidade :int = 0
@export var defesa :int = 0
@export var forca :int = 0
@export var velocidade :int = 0
@export var inteligencia :int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
const SPEED = 300.0

func _physics_process(delta: float) -> void:
	# =========== SISTEMA PARA ANDAR ================
	
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	# ===============================================

	move_and_slide()
