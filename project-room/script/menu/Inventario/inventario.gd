extends Node
class_name Inventario

const TAMANHO_INVENTARIO = 20
var inventario: Array = []
var itens = Itens


func _ready():
	inventario.resize(TAMANHO_INVENTARIO) # índices 0–19 (slots 1–20)


func _pegar_menor_slot_livre() -> int:
	for i in range(inventario.size()):
		if inventario[i] == null:
			return i
	return -1


func adicionar_item(nome: String, quantidade: int, tipo: String) -> bool:
	# 1. Verifica se já existe no inventário
	for i in range(inventario.size()):
		var item = inventario[i]
		
		if item != null and nome in item:
			# pega o dicionário interno
			var dados = item[nome]
			
			# 2. só empilha se for do tipo "inventario"
			if dados["tipo"] == "inventario":
				dados["quantidade"] += quantidade
				return true
			
			break # existe mas não empilha
	
	# 3. não existe ou não empilha → adiciona novo slot
	var slot = _pegar_menor_slot_livre()
	
	if slot == -1:
		return false
	
	inventario[slot] = {
		(nome): {
			"quantidade": quantidade,
			"tipo": tipo,
			"idSlot": slot + 1
		}
	}
	
	return true
	
	
func remover_item(nome: String) -> bool:
	for i in range(inventario.size()):
		var item = inventario[i]
		
		if item != null and nome in item:
			inventario[i] = null
			return true
	
	return false
