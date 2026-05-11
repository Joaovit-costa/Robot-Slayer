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


func configurar(player):
	player_ref = player
	atualizar_menu_status()


func atualizar_menu_status():
	if player_ref == null:
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


func aumentar_atributo(nome):
	if player_ref == null or player_ref.pontosStatus <= 0:
		return

	match nome:
		"forca": player_ref.forca += 1
		"defesa": player_ref.defesa += 1
		"vitalidade": player_ref.vitalidade += 1
		"inteligencia": player_ref.inteligencia += 1

	player_ref.pontosStatus -= 1
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
