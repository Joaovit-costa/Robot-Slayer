extends CanvasLayer

@onready var fundo: AnimatedSprite2D = $AnimatedSprite2D
@onready var sala: Node2D = $".."

var ativa: bool = false


func _ready() -> void:
	add_to_group("tela_morte")
	
	# A tela de morte precisa continuar funcionando
	# mesmo quando o jogo estiver pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	fundo.z_index = 1970
	fundo.z_index = 1975
	
	# Garante que fique acima das outras interfaces.
	layer = 10
	
	visible = false
	fundo.modulate.a = 0.0


func exibir() -> void:
	ativa = true
	visible = true
	
	fundo.modulate.a = 0.0
	fundo.play()
	
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
	if not ativa:
		return
	
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
	
	_trocar_sala()


func _trocar_sala() -> void:
	if sala == null or not sala.has_method("solicitar_transicao_de_sala"):
		push_error("Gerenciador de salas nao encontrado.")
		return

	# O recuo preserva o tutorial e nao e compensado pelo incremento normal
	# de uma transicao feita pela porta.
	var salas_recuadas := Balanceamento.salas_recuadas_ao_morrer(
		sala.salas_passadas
	)
	if sala.salas_passadas >= Balanceamento.PRIMEIRA_SALA_FORA_DO_TUTORIAL:
		sala.salas_passadas = maxi(
			sala.salas_passadas - salas_recuadas,
			Balanceamento.PRIMEIRA_SALA_FORA_DO_TUTORIAL
		)
	await sala.solicitar_transicao_de_sala(sala, "", false)
	SaveManager.solicitar_salvamento()
