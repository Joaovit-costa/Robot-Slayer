extends Node

@onready var musica = $Musica

var musica_atual: AudioStream = null

func tocar_musica(stream: AudioStream):
	if stream == null:
		return

	# Evita reiniciar a mesma música
	if musica_atual == stream:
		return

	musica_atual = stream
	musica.stream = stream
	musica.play()


func parar_musica():
	musica.stop()
	musica_atual = null
