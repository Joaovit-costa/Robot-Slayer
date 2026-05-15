extends Node

@onready var musica = $Musica
@onready var passo = $SFX/Passo

var musica_atual: AudioStream = null


func _ready() -> void:

	passo.process_mode = Node.PROCESS_MODE_PAUSABLE
	musica.process_mode = Node.PROCESS_MODE_PAUSABLE


# ================= MUSICA =================
func tocar_musica(stream: AudioStream):

	if stream == null:
		return

	if musica_atual == stream:
		return

	musica_atual = stream

	musica.stream = stream
	musica.play()


func parar_musica():

	musica.stop()
	musica_atual = null
# =========================================


# ================= SFX ====================
func tocar_sfx(stream: AudioStream, volume_db: float = 0):

	if stream == null:
		return

	var player = AudioStreamPlayer.new()

	add_child(player)

	player.stream = stream
	player.volume_db = volume_db

	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	player.play()

	player.finished.connect(func():
		player.queue_free()
	)
# ==========================================


# ================= PASSO ==================
func iniciar_passo(stream: AudioStream):

	if get_tree().paused:
		return

	if passo.stream != stream:
		passo.stream = stream

	if not passo.playing:

		passo.volume_db = 5

		if passo.stream is AudioStreamWAV:
			(passo.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

		passo.play()


func parar_passo():

	if passo.playing:
		passo.stop()
# ==========================================
