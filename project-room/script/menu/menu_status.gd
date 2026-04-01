extends Control

# Referência para o protagonista
@export var player: protagonista

# Quantidade de pontos disponíveis para gastar
@export var pontos_status: int = 0

# Referência ao texto que mostra os pontos disponíveis
@onready var texto_pontos_status = $PainelPrincipal/Margem/ConteudoStatus/TextoPontosStatus

# Referências aos textos que mostram o valor de cada atributo
@onready var valor_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/ValorForca
@onready var valor_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/ValorDefesa
@onready var valor_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/ValorVitalidade
@onready var valor_velocidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVelocidade/ValorVelocidade
@onready var valor_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/ValorInteligencia

# Referências aos botões de aumentar atributo
@onready var botao_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/BotaoAdicionarForca
@onready var botao_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/BotaoAdicionarDefesa
@onready var botao_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/BotaoAdicionarVitalidade
@onready var botao_velocidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVelocidade/BotaoAdicionarVelocidade
@onready var botao_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/BotaoAdicionarInteligencia

# Referência ao botão de fechar o menu
@onready var botao_fechar = $PainelPrincipal/BotaoFechar


func _ready() -> void:
	# Atualiza a interface assim que a cena carregar
	atualizar_menu_status()


func atualizar_menu_status() -> void:
	# Se não houver player ligado, não faz nada
	if player == null:
		return

	# Atualiza o texto dos pontos disponíveis
	texto_pontos_status.text = "Pontos de Status: %d" % pontos_status

	# Puxa os valores reais do protagonista.gd
	valor_forca.text = str(player.forca)
	valor_defesa.text = str(player.defesa)
	valor_vitalidade.text = str(player.vitalidade)
	valor_velocidade.text = str(player.velocidade)
	valor_inteligencia.text = str(player.inteligencia)

	# Verifica se ainda pode gastar pontos
	var pode_gastar := pontos_status > 0

	# Ativa ou desativa os botões
	botao_forca.disabled = !pode_gastar
	botao_defesa.disabled = !pode_gastar
	botao_vitalidade.disabled = !pode_gastar
	botao_velocidade.disabled = !pode_gastar
	botao_inteligencia.disabled = !pode_gastar

	# Atualiza o visual dos botões
	atualizar_visual_botoes(pode_gastar)


func atualizar_visual_botoes(pode_gastar: bool) -> void:
	# Se houver pontos, os botões ficam com a cor normal
	if pode_gastar:
		botao_forca.modulate = Color(1, 1, 1, 1)
		botao_defesa.modulate = Color(1, 1, 1, 1)
		botao_vitalidade.modulate = Color(1, 1, 1, 1)
		botao_velocidade.modulate = Color(1, 1, 1, 1)
		botao_inteligencia.modulate = Color(1, 1, 1, 1)
	else:
		# Se não houver pontos, os botões ficam mais escuros
		var cor_desativada := Color(0.75, 0.75, 0.75, 1)
		botao_forca.modulate = cor_desativada
		botao_defesa.modulate = cor_desativada
		botao_vitalidade.modulate = cor_desativada
		botao_velocidade.modulate = cor_desativada
		botao_inteligencia.modulate = cor_desativada


func aumentar_atributo(nome_atributo: String) -> void:
	# Impede gastar ponto se não houver player ou pontos disponíveis
	if player == null:
		return

	if pontos_status <= 0:
		return

	# Aumenta o atributo diretamente no protagonista.gd
	match nome_atributo:
		"forca":
			player.forca += 1
		"defesa":
			player.defesa += 1
		"vitalidade":
			player.vitalidade += 1
		"velocidade":
			player.velocidade += 1
		"inteligencia":
			player.inteligencia += 1

	# Remove 1 ponto de status
	pontos_status -= 1

	# Atualiza a interface depois da mudança
	atualizar_menu_status()


func _on_botao_adicionar_forca_pressed() -> void:
	# Aumenta o atributo força
	aumentar_atributo("forca")


func _on_botao_adicionar_defesa_pressed() -> void:
	# Aumenta o atributo defesa
	aumentar_atributo("defesa")


func _on_botao_adicionar_vitalidade_pressed() -> void:
	# Aumenta o atributo vitalidade
	aumentar_atributo("vitalidade")


func _on_botao_adicionar_velocidade_pressed() -> void:
	# Aumenta o atributo velocidade
	aumentar_atributo("velocidade")


func _on_botao_adicionar_inteligencia_pressed() -> void:
	# Aumenta o atributo inteligência
	aumentar_atributo("inteligencia")


func _on_botao_fechar_pressed() -> void:
	# Esconde o menu de status
	hide()
