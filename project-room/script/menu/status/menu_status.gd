extends Control

var player_ref: protagonista

@onready var texto_pontos_status = $PainelPrincipal/Margem/ConteudoStatus/TextoPontosStatus
@onready var valor_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/ValorForca
@onready var valor_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/ValorDefesa
@onready var valor_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/ValorVitalidade
@onready var valor_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/ValorInteligencia

@onready var botao_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/BotaoAdicionarForca
@onready var botao_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/BotaoAdicionarDefesa
@onready var botao_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/BotaoAdicionarVitalidade
@onready var botao_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/BotaoAdicionarInteligencia


func _ready():
	add_to_group("menu_status")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_buscar_player()
	atualizar_menu_status()
	
	
func configurar(player):
	player_ref = player
	atualizar_menu_status()


func _process(_delta):
	if visible:
		if player_ref == null:
			_buscar_player()
		atualizar_menu_status()
		
		
func _buscar_player():
	var player := get_tree().get_first_node_in_group("player") as protagonista
	
	if player != null:
		player_ref = player



func atualizar_menu_status():
	if player_ref == null:
		_buscar_player()
		
	if player_ref == null:
		_desabilitar_botoes_status()
		return

	texto_pontos_status.text = "Pontos de Status: %d" % player_ref.pontosStatus

	valor_forca.text = str(player_ref.forca)
	valor_defesa.text = str(player_ref.defesa)
	valor_vitalidade.text = str(player_ref.vitalidade)
	valor_inteligencia.text = str(player_ref.inteligencia)

	var pode_gastar: bool = player_ref.pontosStatus > 0

	botao_forca.disabled = !pode_gastar
	botao_defesa.disabled = !pode_gastar
	botao_vitalidade.disabled = !pode_gastar
	botao_inteligencia.disabled = !pode_gastar


func _desabilitar_botoes_status():
	botao_forca.disabled = true
	botao_defesa.disabled = true
	botao_vitalidade.disabled = true
	botao_inteligencia.disabled = true
	
	
func aumentar_atributo(nome):
	if player_ref == null or player_ref.pontosStatus <= 0:
		return

	if player_ref.aumentar_atributo(nome):
		atualizar_menu_status()


func _on_botao_adicionar_forca_pressed():
	aumentar_atributo("forca")

func _on_botao_adicionar_defesa_pressed():
	aumentar_atributo("defesa")

func _on_botao_adicionar_vitalidade_pressed():
	aumentar_atributo("vitalidade")

func _on_botao_adicionar_inteligencia_pressed():
	aumentar_atributo("inteligencia")

func _on_botao_fechar_pressed():
	hide()
	get_tree().paused = false
	
