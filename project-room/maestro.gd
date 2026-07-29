extends Node

@onready var node_2d: Node2D = $Node2D
@onready var menu_inicial: Control = $MenuInicial
@onready var pause_menu: CanvasLayer = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node_2d.visible = false
	node_2d.PROCESS_MODE_DISABLED
	
	pause_menu.visible = false
	pause_menu.PROCESS_MODE_DISABLED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.visible = true
		pause_menu.PROCESS_MODE_INHERIT





func _on_entrar_pressed() -> void:
	node_2d.visible = true
	node_2d.PROCESS_MODE_INHERIT


func _on_sair_pressed() -> void:
	get_tree().quit()
