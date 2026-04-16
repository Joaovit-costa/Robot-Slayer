extends Control

# Quantidade de pontos disponíveis para gastar
var pontos_status: int = 3

# Dicionário com os valores atuais dos atributos
var atributos := {
	"forca": 0,
	"defesa": 0,
	"vitalidade": 0,
	"inteligencia": 0
}

# Referência ao texto que mostra os pontos disponíveis
@onready var texto_pontos_status = $PainelPrincipal/Margem/ConteudoStatus/TextoPontosStatus

# Referências aos textos que mostram o valor de cada atributo
@onready var valor_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/ValorForca
@onready var valor_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/ValorDefesa
@onready var valor_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/ValorVitalidade
@onready var valor_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/ValorInteligencia

# Referências aos botões de aumentar atributo
@onready var botao_forca = $PainelPrincipal/Margem/ConteudoStatus/LinhaForca/BotaoAdicionarForca
@onready var botao_defesa = $PainelPrincipal/Margem/ConteudoStatus/LinhaDefesa/BotaoAdicionarDefesa
@onready var botao_vitalidade = $PainelPrincipal/Margem/ConteudoStatus/LinhaVitalidade/BotaoAdicionarVitalidade
@onready var botao_inteligencia = $PainelPrincipal/Margem/ConteudoStatus/LinhaInteligencia/BotaoAdicionarInteligencia

# Referência ao botão de fechar o menu
@onready var botao_fechar = $PainelPrincipal/BotaoFechar


func _ready() -> void:
	# Atualiza a interface assim que a cena carregar
	atualizar_menu_status()


func atualizar_menu_status() -> void:
	# Atualiza o texto dos pontos disponíveis
	texto_pontos_status.text = "Pontos de Status: %d" % pontos_status

	# Atualiza os valores visuais dos atributos
	valor_forca.text = str(atributos["forca"]) 
	valor_defesa.text = str(atributos["defesa"])
	valor_vitalidade.text = str(atributos["vitalidade"])
	valor_inteligencia.text = str(atributos["inteligencia"])

	# Verifica se o jogador ainda pode gastar pontos
	var pode_gastar := pontos_status > 0

	# Ativa ou desativa os botões de acordo com a quantidade de pontos
	botao_forca.disabled = !pode_gastar
	botao_defesa.disabled = !pode_gastar
	botao_vitalidade.disabled = !pode_gastar
	botao_inteligencia.disabled = !pode_gastar

	# Atualiza a aparência dos botões
	atualizar_visual_botoes(pode_gastar)


func atualizar_visual_botoes(pode_gastar: bool) -> void:
	# Se houver pontos, os botões ficam com a cor normal
	if pode_gastar:
		botao_forca.modulate = Color(1, 1, 1, 1)
		botao_defesa.modulate = Color(1, 1, 1, 1)
		botao_vitalidade.modulate = Color(1, 1, 1, 1)
		botao_inteligencia.modulate = Color(1, 1, 1, 1)
	else:
		# Se não houver pontos, os botões ficam mais escuros
		var cor_desativada := Color(0.75, 0.75, 0.75, 1)
		botao_forca.modulate = cor_desativada
		botao_defesa.modulate = cor_desativada
		botao_vitalidade.modulate = cor_desativada
		botao_inteligencia.modulate = cor_desativada


func aumentar_atributo(nome_atributo: String) -> void:
	# Impede gastar ponto se não houver nenhum disponível
	if pontos_status <= 0:
		return

	# Aumenta o atributo escolhido em 1
	atributos[nome_atributo] += 1

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

func _on_botao_adicionar_inteligencia_pressed() -> void:
	# Aumenta o atributo inteligência
	aumentar_atributo("inteligencia")

func _on_botao_fechar_pressed() -> void:
	# Esconde o menu de status
	hide()
