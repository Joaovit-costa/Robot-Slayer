extends Sala

@onready var texture_rect_2: TextureRect = $Area2D/TextureRect2
var inimigos_na_parede = []

func _on_area_2d_body_entered(body: Node2D) -> void:
	texture_rect_2.modulate.a = 0.3
	inimigos_na_parede.append(body)



func _on_area_2d_body_exited(body: Node2D) -> void:
	inimigos_na_parede.erase(body)
	
	if inimigos_na_parede == []:
		texture_rect_2.modulate.a = 1
	
