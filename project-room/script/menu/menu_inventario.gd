extends Control

# Itens de teste
@export var item_teste_1: Item
@export var item_teste_2: Item
@export var item_teste_3: Item

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
	colocar_itens_teste()
	print(inventario["inventario"])

func pegar_slots() -> void:
	for slot in $PainelPrincipal/Conteudo/PainelEsquerdo/ChipsArma.get_children():
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
		slots_equipamento[i].tipo_slot = "equipamento"

	slots_equipamento[0].definir_bloqueio(false)

	for i in range(1, slots_equipamento.size()):
		slots_equipamento[i].definir_bloqueio(true)


func colocar_itens_teste() -> void:
	if item_teste_1 != null and item_teste_1.tipo == "equipamento":
		slots_inventario[0].definir_item(item_teste_1)

	if item_teste_2 != null and item_teste_2.tipo == "equipamento":
		slots_inventario[1].definir_item(item_teste_2)

	if item_teste_3 != null and item_teste_3.tipo == "chip":
		slots_chips[0].definir_item(item_teste_3)
func _on_botao_fechar_pressed() -> void:
	# Esconde o menu de inventário
	hide()
