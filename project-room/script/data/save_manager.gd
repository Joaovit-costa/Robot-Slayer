extends Node

const SAVE_PATH := "user://save_player.json"
const INTERVALO_AUTOSAVE_SEGUNDOS := 600.0

var dados: Dictionary = {}
var save_carregado: bool = false
var salvamento_pendente: bool = false
var aplicando_save: bool = false
var timer_autosave: Timer


func _ready() -> void:
	carregar()
	_configurar_autosave()


func carregar() -> Dictionary:
	if save_carregado:
		return dados

	save_carregado = true
	if not FileAccess.file_exists(SAVE_PATH):
		dados = {}
		return dados

	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if arquivo == null:
		dados = {}
		return dados

	var texto := arquivo.get_as_text()
	var json := JSON.new()
	if json.parse(texto) != OK or typeof(json.data) != TYPE_DICTIONARY:
		dados = {}
		return dados

	dados = json.data
	return dados


func tem_save() -> bool:
	carregar()
	return not dados.is_empty()


func aplicar_no_player(player: protagonista) -> void:
	if player == null:
		return

	carregar()
	if not dados.has("player"):
		return

	aplicando_save = true
	var player_data: Dictionary = dados.get("player", {})

	player.vitalidade = max(1, int(player_data.get("vitalidade", player.vitalidade)))
	player.vidaInicial = max(1, int(player_data.get("vidaInicial", player.calcular_vida_maxima())))
	player.vidaAtual = max(0, int(player_data.get("vidaAtual", player.vidaInicial)))
	player.defesa = max(0, int(player_data.get("defesa", player.defesa)))
	player.forca = max(1, int(player_data.get("forca", player_data.get("dano", player.forca))))
	player.inteligencia = max(0, int(player_data.get("inteligencia", player.inteligencia)))
	player.pontosExperiencia = max(0, int(player_data.get("pontosExperiencia", player.pontosExperiencia)))
	player.experiencia = max(0, int(player_data.get("experiencia", player.experiencia)))
	player.nivel = max(1, int(player_data.get("nivel", player.nivel)))
	player.moedas = max(0, int(player_data.get("moedas", player.moedas)))
	player.pontosStatus = max(0, int(player_data.get("pontosStatus", player.pontosStatus)))
	player.experienciaNecessaria = max(1, int(player_data.get("experienciaNecessaria", player.experienciaNecessaria)))
	player.cooldownDaCura = maxf(0.0, float(player_data.get("cooldownDaCura", player.cooldownDaCura)))
	player.inimigos_derrotados_usando_missil_reto = max(0,
	int(
		player_data.get(
		"inimigos_derrotados_usando_missil_reto",
		player.inimigos_derrotados_usando_missil_reto
	))
)

	player.dano_recebido_sem_morrer = max(
		0,
		int(player_data.get(
			"dano_recebido_sem_morrer",
			player.dano_recebido_sem_morrer
		))
	)

	player.derrotados_utilizando_dash = max(
		0,
		int(player_data.get(
			"derrotados_utilizando_dash",
			player.derrotados_utilizando_dash
		))
	)

	player.salas_dificeis_sem_cura = max(
		0,
		int(player_data.get(
			"salas_dificeis_sem_cura",
			player.salas_dificeis_sem_cura
		))
	)
	player.sincronizar_vida()
	aplicando_save = false


func aplicar_no_inventario(inventario: Inventario) -> void:
	if inventario == null:
		return

	carregar()
	if not dados.has("inventario"):
		return

	aplicando_save = true
	var itens: Array = dados.get("inventario", [])
	inventario.carregar_itens(itens)
	aplicando_save = false


func aplicar_no_gerenciador_salas(gerenciador: Node) -> void:
	if gerenciador == null:
		return

	carregar()
	if dados.has("salas_passadas"):
		gerenciador.set("salas_passadas", int(dados.get("salas_passadas", 0)))
	if dados.has("sala_atual_id"):
		gerenciador.set("sala_atual_id", str(dados.get("sala_atual_id", "")))
	elif dados.has("player"):
		var player_data: Dictionary = dados.get("player", {})
		gerenciador.set("sala_atual_id", str(player_data.get("sala_atual_id", "")))


func aplicar_no_tutorial(controlador: ControladorTutorial) -> void:
	if controlador == null:
		return

	carregar()
	var etapa_salva := int(dados.get("tutorial_etapa", controlador.tutorial))
	# A etapa 19 era a conclusao antes da inclusao do tutorial de cura.
	if int(dados.get("tutorial_versao", 1)) < 2 and etapa_salva >= 19:
		etapa_salva = ControladorTutorial.ETAPA_CONCLUIDA

	controlador.tutorial = clampi(
		etapa_salva,
		controlador.ETAPA_MOVIMENTACAO,
		controlador.ETAPA_CONCLUIDA
	)

func aplicar_no_gerenciador_habilidades(gerenciador: Node) -> void:
	if gerenciador == null:
		return

	carregar()

	if not dados.has("habilidades_equipadas"):
		return

	var habilidades: Array = dados.get("habilidades_equipadas", [])

	aplicando_save = true

	gerenciador.carregar_habilidades_equipadas(habilidades)

	aplicando_save = false

func aplicar_habilidades_desbloqueadas() -> void:
	carregar()

	if not dados.has("habilidades_desbloqueadas"):
		return

	var gerenciador_habilidades = get_tree().get_first_node_in_group(
		"Main"
	)

	if gerenciador_habilidades == null:
		return

	var habilidades: Dictionary = dados.get(
		"habilidades_desbloqueadas",
		{}
	)

	gerenciador_habilidades.habilidade1_desbloqueada = bool(
		habilidades.get("habilidade1", false)
	)

	gerenciador_habilidades.habilidade2_desbloqueada = bool(
		habilidades.get("habilidade2", false)
	)

	gerenciador_habilidades.habilidade3_desbloqueada = bool(
		habilidades.get("habilidade3", false)
	)

	gerenciador_habilidades.habilidade4_desbloqueada = bool(
		habilidades.get("habilidade4", false)
	)

	gerenciador_habilidades.habilidade5_desbloqueada = bool(
		habilidades.get("habilidade5", false)
	)

	gerenciador_habilidades.habilidade6_desbloqueada = bool(
		habilidades.get("habilidade6", false)
	)

func salvar_estado_atual() -> void:
	carregar()

	var player := get_tree().get_first_node_in_group("protagonista") as protagonista
	if player == null:
		player = get_tree().get_first_node_in_group("player") as protagonista
	if player != null:
		dados["player"] = _coletar_player(player)

	var inventario := get_tree().get_first_node_in_group("inventario_principal") as Inventario
	if inventario != null:
		dados["inventario"] = inventario.get_lista_itens()
	
	var gerenciador_habilidades := _buscar_gerenciador_habilidades()

	if gerenciador_habilidades != null:
		dados["habilidades_equipadas"] = gerenciador_habilidades.get_habilidades_equipadas()

	var gerenciador := _buscar_gerenciador_salas()
	if gerenciador != null:
		dados["salas_passadas"] = int(gerenciador.get("salas_passadas"))
		dados["sala_atual_id"] = str(gerenciador.get("sala_atual_id"))
		if dados.has("player"):
			dados["player"]["sala_atual_id"] = str(gerenciador.get("sala_atual_id"))
	var main = get_tree().get_first_node_in_group(
		"Main"
	)

	if main != null:
		dados["habilidades_desbloqueadas"] = {
			"habilidade1": main.habilidade1_desbloqueada,
			"habilidade2": main.habilidade2_desbloqueada,
			"habilidade3": main.habilidade3_desbloqueada,
			"habilidade4": main.habilidade4_desbloqueada,
			"habilidade5": main.habilidade5_desbloqueada,
			"habilidade6": main.habilidade6_desbloqueada
		}
		
	var controlador_tutorial := get_tree().get_first_node_in_group("controlador_tutorial") as ControladorTutorial
	if controlador_tutorial != null:
		dados["tutorial_etapa"] = controlador_tutorial.tutorial
		dados["tutorial_versao"] = 2

	_salvar_no_disco()


func solicitar_salvamento() -> void:
	if aplicando_save or salvamento_pendente:
		return

	salvamento_pendente = true
	call_deferred("_salvar_pendente")


func _salvar_pendente() -> void:
	salvamento_pendente = false
	salvar_estado_atual()


func _configurar_autosave() -> void:
	timer_autosave = Timer.new()
	timer_autosave.wait_time = INTERVALO_AUTOSAVE_SEGUNDOS
	timer_autosave.one_shot = false
	timer_autosave.autostart = true
	timer_autosave.timeout.connect(_on_timer_autosave_timeout)
	add_child(timer_autosave)


func _on_timer_autosave_timeout() -> void:
	solicitar_salvamento()


func _coletar_player(player: protagonista) -> Dictionary:
	return {
		"vitalidade": player.vitalidade,
		"vidaInicial": player.vidaInicial,
		"vidaAtual": player.vidaAtual,
		"defesa": player.defesa,
		"forca": player.forca,
		"dano": player.forca,
		"inteligencia": player.inteligencia,
		"pontosExperiencia": player.pontosExperiencia,
		"experiencia": player.experiencia,
		"nivel": player.nivel,
		"moedas": player.moedas,
		"pontosStatus": player.pontosStatus,
		"experienciaNecessaria": player.experienciaNecessaria,
		"cooldownDaCura": player.cooldownDaCura,
		"inimigos_derrotados_usando_missil_reto": player.inimigos_derrotados_usando_missil_reto,
		"dano_recebido_sem_morrer": player.dano_recebido_sem_morrer,
		"derrotados_utilizando_dash": player.derrotados_utilizando_dash,
		"salas_dificeis_sem_cura": player.salas_dificeis_sem_cura,
		"sala_atual_id": str(dados.get("sala_atual_id", ""))
	}


func _salvar_no_disco() -> void:
	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if arquivo == null:
		push_warning("Nao foi possivel salvar em %s" % SAVE_PATH)
		return

	arquivo.store_string(JSON.stringify(dados, "\t"))
	arquivo.close()


func _buscar_gerenciador_salas() -> Node:
	for node in get_tree().get_nodes_in_group("gerenciador_salas"):
		if node != null and is_instance_valid(node):
			return node
	return null

func _buscar_gerenciador_habilidades() -> Node:
	for node in get_tree().get_nodes_in_group("gerenciador_habilidades"):
		if node != null and is_instance_valid(node):
			return node

	return null
