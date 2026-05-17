extends Node2D

@export_file("*.tscn") var proxima_sala_path: String


func _on_area_2d_body_entered(body: Node) -> void:
	var player := body as protagonista
	if player == null:
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
