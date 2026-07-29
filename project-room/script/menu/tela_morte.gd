extends CanvasLayer

@onready var fundo: ColorRect = $ColorRect
@onready var sala: Node2D = $".."

var ativa: bool = false


func _ready() -> void:
	add_to_group("tela_morte")
	visible = false
	fundo.modulate.a = 0.0


func exibir() -> void:
	ativa = true
	visible = true

	fundo.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(
		fundo,
		"modulate:a",
		1.0,
		1.5
	)


func _unhandled_input(event: InputEvent) -> void:
	if not ativa:
		return
		
	if event is InputEventMouseButton:
		if event.pressed:
			_continuar()

	elif event is InputEventScreenTouch:
		if event.pressed:
			_continuar()
	
	elif event is InputEventKey:
		if event.pressed:
			_continuar()


func _continuar() -> void:
	ativa = false

	var tween := create_tween()

	tween.tween_property(
		fundo,
		"modulate:a",
		0.0,
		0.8
	)

	await tween.finished

	visible = false
	
	var protagonista = get_tree().get_first_node_in_group("protagonista")

	if protagonista != null:
		protagonista.restaurar_vida()

	# Troca de sala
	_trocar_sala()


func _trocar_sala() -> void:
	var sala_atual := get_tree().current_scene
	
	# Exemplo temporário
	sala.solicitar_transicao_de_sala(sala_atual)
	sala.salas_passadas -= 5
	SaveManager.solicitar_salvamento()
