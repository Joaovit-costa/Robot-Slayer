extends Control

# Itens de teste
const ListaItensScript = preload("res://script/menu/lista_itens.gd")
var itens = ListaItensScript.new()

# Arrays para guardar referências dos slots
var slots_chips: Array = []
var slots_inventario: Array = []
var slots_equipamento: Array = []

var inventario = {
	"inventario": [
		{
			"nome": "",
			"tipo": "",
			"raridade": "",
			"quantidade": 0,
			"descricao": "",
			"imagem": null,
			"id_slot": -1
		}
	],
	"equipado": [
		{
			"nome": "",
			"raridade": "",
			"imagem": null
		}
	],
	"extensor": [
		{
			
		}
	]
}


func _ready() -> void:
	pegar_slots()
	configurar_slots()

	# Coloca os primeiros itens nos slots
	for i in range(min(slots_inventario.size(), itens.itens.size())):
		var item = itens.itens[i]
		slots_inventario[i].definir_item(item)
	 
func pegar_slots() -> void:
	for slot in $PainelPrincipal/Conteudo/PainelEsquerdo/SlotsExtensores.get_children():
		slots_chips.append(slot)

	for slot in $PainelPrincipal/Conteudo/PainelDireito/GradeInventario.get_children():
		slots_inventario.append(slot)

	for slot in $PainelPrincipal/Conteudo/PainelDireito/SlotsEquipamento.get_children():
		slots_equipamento.append(slot)

	print("Chips:", slots_chips.size())
	print("Inventário:", slots_inventario.size())
	print("Equipamento:", slots_equipamento.size())


func configurar_slots() -> void:
	for slot in slots_chips:
		slot.tipo_slot = "chip"
		slot.definir_bloqueio(false)

	for slot in slots_inventario:
		slot.tipo_slot = "inventario"
		slot.definir_bloqueio(false)

	for i in range(slots_equipamento.size()):
		slots_equipamento[0].definir_bloqueio(false)
		slots_equipamento[1].definir_bloqueio(false)

	for i in range(2, slots_equipamento.size()):
		slots_equipamento[i].definir_bloqueio(true)


func _on_botao_fechar_pressed() -> void:
	# Esconde o menu de inventário
	hide()
