extends Node2D

@export_file("*.tscn") var proxima_sala_path: String


func _on_area_2d_body_entered(body: Node) -> void:
	var player := body as protagonista
	if player == null:
		return

	var gerenciador_salas := _buscar_gerenciador_salas()
	if gerenciador_salas != null:
		gerenciador_salas.solicitar_transicao_de_sala(
			self,
			proxima_sala_path
		)
		return

	var player_position := player.global_position
	var proxima_sala := load(proxima_sala_path) as PackedScene
	if proxima_sala == null:
		return

	var nova_sala := proxima_sala.instantiate() as Node2D
	if nova_sala == null:
		return

	var parent_node := get_parent()
	parent_node.add_child(nova_sala)
	parent_node.move_child(nova_sala, get_index())

	var novo_player := nova_sala.get_node_or_null("Protagonista") as Node2D
	if novo_player != null:
		novo_player.global_position = player_position

	if get_tree().current_scene == self:
		get_tree().current_scene = nova_sala

	queue_free()


func _buscar_gerenciador_salas() -> Node:
	var node_atual := get_parent()

	while node_atual != null:
		if node_atual.has_method("solicitar_transicao_de_sala"):
			return node_atual

		node_atual = node_atual.get_parent()

	return null
