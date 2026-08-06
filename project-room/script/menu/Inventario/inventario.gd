extends Node
class_name Inventario

# Sinal usado pela interface para redesenhar os slots quando a lista muda.
signal inventario_atualizado
const CENA_BANCO_ITENS := preload("res://res/Cenas/Data/itens.tscn")

# Constantes de tipo para manter a validacao dos slots padronizada.
const SLOT_INVENTARIO := "inventario"
const SLOT_EQUIPAVEL := "equipavel"
const SLOT_EXTENSOR := "extensor"

# Grupos de slots usados para mochila, equipamentos e extensores.
const SLOTS_MOCHILA := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
const SLOTS_EQUIPAVEIS := [21, 22, 23, 24]
const SLOTS_EXTENSORES := [25, 26]
const TODOS_SLOTS := [
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
	11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
	21, 22, 23, 24, 25, 26
]

# Lista principal do inventario e referencia ao banco mestre dos itens.
var inventario: Array[Dictionary] = []
var banco_itens: Itens

func _ready() -> void:
	_configurar_banco_de_itens()

func _configurar_banco_de_itens() -> void:
	if banco_itens != null:
		return

	var banco_instanciado := CENA_BANCO_ITENS.instantiate()
	banco_itens = banco_instanciado as Itens

	if banco_itens != null:
		add_child(banco_itens)

# Informa qual categoria de slot existe em um id especifico.
func get_tipo_slot(id_slot: int) -> String:
	if id_slot in SLOTS_EXTENSORES:
		return SLOT_EXTENSOR
	if id_slot in SLOTS_EQUIPAVEIS:
		return SLOT_EQUIPAVEL
	return SLOT_INVENTARIO


# Retorna uma copia ordenada da lista para leitura externa.
func get_lista_itens() -> Array[Dictionary]:
	var lista := inventario.duplicate(true)
	lista.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("idSlot", 0)) < int(b.get("idSlot", 0))
	)
	return lista


func carregar_itens(novos_itens: Array) -> void:
	inventario.clear()

	for item in novos_itens:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_dict: Dictionary = item
		var nome := str(item_dict.get("nome", "")).strip_edges()
		var dados_item := buscar_info_item(nome)
		var slot := int(item_dict.get("idSlot", -1))
		var tipo := _resolver_tipo_item(dados_item)
		if nome.is_empty() or tipo.is_empty() or slot not in TODOS_SLOTS:
			continue
		if not item_pode_ir_para_slot(tipo, slot) or not get_item_no_slot(slot).is_empty():
			continue
		item_dict["nome"] = nome
		item_dict["tipo"] = tipo
		item_dict["idSlot"] = slot
		item_dict["quantidade"] = max(1, int(item_dict.get("quantidade", 1)))
		item_dict["raridade"] = clampi(int(item_dict.get("raridade", ItensData.Raridade.COMUM)), ItensData.Raridade.COMUM, ItensData.Raridade.LENDARIO)
		inventario.append(item_dict.duplicate(true))
		
	_normalizar_slots_bloqueados()
	_emitir_atualizacao()


# Procura o registro salvo em um slot especifico.
func get_item_no_slot(id_slot: int) -> Dictionary:
	for item in inventario:
		if int(item.get("idSlot", -1)) == id_slot:
			return item
	return {}


# Consulta o banco de itens usando o nome salvo no inventario.
func buscar_info_item(nome: String) -> ItensData:
	if banco_itens == null:
		return null
	return banco_itens.buscar_item_por_nome(nome)


# Adiciona item novo, empilha itens de mochila e salva a raridade no registro.
func adicionar_item(nome: String, raridade: int, quantidade: int = 1, id_slot: int = -1) -> bool:
	var dados_item := buscar_info_item(nome)
	var tipo_final := _resolver_tipo_item(dados_item)	
	
	if tipo_final.is_empty():
		return false

	if tipo_final == SLOT_INVENTARIO:
		var item_empilhado := _buscar_item_empilhavel(nome, raridade)
		if not item_empilhado.is_empty():
			item_empilhado["quantidade"] = int(item_empilhado.get("quantidade", 0)) + quantidade
			_atualizar_item_por_slot(int(item_empilhado.get("idSlot", -1)), item_empilhado)
			_emitir_atualizacao()
			_solicitar_salvamento()
			return true

	var slot_destino := id_slot
	if slot_destino == -1:
		slot_destino = _pegar_primeiro_slot_livre(SLOTS_MOCHILA)

	if slot_destino == -1:
		return false
	if not slot_esta_habilitado(slot_destino):
		return false
	if not item_pode_ir_para_slot(tipo_final, slot_destino):
		return false
	if not get_item_no_slot(slot_destino).is_empty():
		return false

	inventario.append({
		"nome": nome,
		"idSlot": slot_destino,
		"quantidade": max(1, quantidade),
		"tipo": tipo_final,
		"raridade": raridade
	})

	_normalizar_slots_bloqueados()
	_emitir_atualizacao()
	_solicitar_salvamento()
	return true


# Verifica se uma compra inteira cabe na mochila sem alterar o inventario atual.
func tem_espaco_para_itens(itens_compra: Array[Dictionary]) -> bool:
	var slots_ocupados := {}
	var pilhas_mochila := {}

	for item in inventario:
		var id_slot := int(item.get("idSlot", -1))
		if id_slot in SLOTS_MOCHILA:
			slots_ocupados[id_slot] = true
		if str(item.get("tipo", "")) == SLOT_INVENTARIO:
			var chave := _criar_chave_pilha(
				str(item.get("nome", "")),
				int(item.get("raridade", ItensData.Raridade.COMUM))
			)
			pilhas_mochila[chave] = true

	for item_compra in itens_compra:
		var nome := str(item_compra.get("nome", ""))
		var raridade := int(item_compra.get("raridade", ItensData.Raridade.COMUM))
		var dados_item := buscar_info_item(nome)
		var tipo_final := _resolver_tipo_item(dados_item)
		if tipo_final.is_empty():
			return false

		var chave := _criar_chave_pilha(nome, raridade)
		if tipo_final == SLOT_INVENTARIO and pilhas_mochila.has(chave):
			continue

		var slot_livre := _pegar_primeiro_slot_livre_simulado(slots_ocupados)
		if slot_livre == -1:
			return false

		slots_ocupados[slot_livre] = true
		if tipo_final == SLOT_INVENTARIO:
			pilhas_mochila[chave] = true

	return true


# Remove um item por nome/slot e desconta quantidade quando for empilhavel.
func remover_item(nome: String, quantidade: int = 1, id_slot: int = -1) -> bool:
	if quantidade <= 0:
		return false
	var indice := _encontrar_indice_item(nome, id_slot)
	if indice == -1:
		return false

	var item := inventario[indice]
	var quantidade_atual := int(item.get("quantidade", 0))
	if quantidade_atual > quantidade and str(item.get("tipo", "")) == SLOT_INVENTARIO:
		item["quantidade"] = quantidade_atual - quantidade
		inventario[indice] = item
	else:
		inventario.remove_at(indice)

	_normalizar_slots_bloqueados()
	_emitir_atualizacao()
	_solicitar_salvamento()
	return true


# Move item entre slots, troca itens ou empilha quando a regra permitir.
func mover_item(slot_origem: int, slot_destino: int) -> bool:
	if slot_origem == slot_destino:
		return false
	if not slot_esta_habilitado(slot_destino):
		return false

	var item_origem := get_item_no_slot(slot_origem)
	if item_origem.is_empty():
		return false

	var item_destino := get_item_no_slot(slot_destino)
	var tipo_origem := str(item_origem.get("tipo", ""))

	if not item_pode_ir_para_slot(tipo_origem, slot_destino):
		return false

	if item_destino.is_empty():
		_remover_item_por_slot(slot_origem)
		item_origem["idSlot"] = slot_destino
		inventario.append(item_origem)
	else:
		var tipo_destino := str(item_destino.get("tipo", ""))
		if _pode_empilhar(item_origem, item_destino, slot_destino):
			item_destino["quantidade"] = int(item_destino.get("quantidade", 0)) + int(item_origem.get("quantidade", 0))
			_atualizar_item_por_slot(slot_destino, item_destino)
			_remover_item_por_slot(slot_origem)
		else:
			if not item_pode_ir_para_slot(tipo_destino, slot_origem):
				return false
			item_origem["idSlot"] = slot_destino
			item_destino["idSlot"] = slot_origem
			_atualizar_item_por_slot(slot_destino, item_origem)
			_atualizar_item_por_slot(slot_origem, item_destino)

	_normalizar_slots_bloqueados()
	_emitir_atualizacao()
	_solicitar_salvamento()
	return true


# Valida se o tipo do item pode entrar no tipo do slot de destino.
func item_pode_ir_para_slot(tipo_item: String, id_slot: int) -> bool:
	var tipo_slot := get_tipo_slot(id_slot)
	if tipo_slot == SLOT_INVENTARIO:
		return true
	return tipo_slot == tipo_item


# Libera ou bloqueia slots extras com base nos extensores equipados.
func slot_esta_habilitado(id_slot: int) -> bool:
	if id_slot in SLOTS_MOCHILA:
		return true
	if id_slot in [21, 22, 25]:
		return true

	var extensores_equipados := _contar_extensores_equipados()

	if id_slot in [23, 26]:
		return extensores_equipados >= 1
	if id_slot == 24:
		return extensores_equipados >= 2

	return true


# Resolve o tipo do item diretamente pelo banco mestre.
func _resolver_tipo_item(dados_item: ItensData) -> String:
	if dados_item == null:
		return ""

	match dados_item.tipo:
		ItensData.TipoItem.EXTENSOR:
			return SLOT_EXTENSOR
		ItensData.TipoItem.EQUIPAVEL:
			return SLOT_EQUIPAVEL
		_:
			return SLOT_INVENTARIO


# Procura um item de mochila com o mesmo nome e raridade para empilhamento.
func _buscar_item_empilhavel(nome: String, raridade: int) -> Dictionary:
	for item in inventario:
		if (
			str(item.get("nome", "")) == nome
			and str(item.get("tipo", "")) == SLOT_INVENTARIO
			and int(item.get("raridade", ItensData.Raridade.COMUM)) == raridade
		):
			return item
	return {}

func _criar_chave_pilha(nome: String, raridade: int) -> String:
	return nome + "|" + str(raridade)


# Encontra o indice interno de um item por nome e, opcionalmente, por slot.
func _encontrar_indice_item(nome: String, id_slot: int = -1) -> int:
	for i in range(inventario.size()):
		var item := inventario[i]
		if str(item.get("nome", "")) != nome:
			continue
		if id_slot != -1 and int(item.get("idSlot", -1)) != id_slot:
			continue
		return i
	return -1


# Busca o primeiro slot vazio dentro do grupo informado.
func _pegar_primeiro_slot_livre(slots_validos: Array) -> int:
	for id_slot in slots_validos:
		if get_item_no_slot(id_slot).is_empty():
			return id_slot
	return -1


func _pegar_primeiro_slot_livre_simulado(slots_ocupados: Dictionary) -> int:
	for id_slot in SLOTS_MOCHILA:
		if not slots_ocupados.has(id_slot):
			return id_slot
	return -1


# Atualiza o registro que ja existe em um slot especifico.
func _atualizar_item_por_slot(id_slot: int, novo_item: Dictionary) -> void:
	for i in range(inventario.size()):
		if int(inventario[i].get("idSlot", -1)) == id_slot:
			inventario[i] = novo_item
			return


# Remove o registro salvo no slot informado.
func _remover_item_por_slot(id_slot: int) -> void:
	for i in range(inventario.size()):
		if int(inventario[i].get("idSlot", -1)) == id_slot:
			inventario.remove_at(i)
			return


# Define quando dois registros podem se unir em um unico slot.
func _pode_empilhar(item_origem: Dictionary, item_destino: Dictionary, slot_destino: int) -> bool:
	return (
		slot_destino in SLOTS_MOCHILA
		and str(item_origem.get("tipo", "")) == SLOT_INVENTARIO
		and str(item_destino.get("tipo", "")) == SLOT_INVENTARIO
		and str(item_origem.get("nome", "")) == str(item_destino.get("nome", ""))
		and int(item_origem.get("raridade", ItensData.Raridade.COMUM)) == int(item_destino.get("raridade", ItensData.Raridade.COMUM))
	)


# Conta quantos extensores validos estao equipados hoje.
func _contar_extensores_equipados() -> int:
	var total := 0
	for id_slot in SLOTS_EXTENSORES:
		var item := get_item_no_slot(id_slot)
		if not item.is_empty() and str(item.get("tipo", "")) == SLOT_EXTENSOR:
			total += 1
	return total


# Recoloca na mochila itens que ficarem presos em slots bloqueados.
func _normalizar_slots_bloqueados() -> void:
	var houve_movimento := true
	while houve_movimento:
		houve_movimento = false
		for id_slot in TODOS_SLOTS:
			if slot_esta_habilitado(id_slot):
				continue
			var item := get_item_no_slot(id_slot)
			if item.is_empty():
				continue
			var novo_slot := _pegar_primeiro_slot_livre(SLOTS_MOCHILA)
			if novo_slot == -1:
				continue
			_remover_item_por_slot(id_slot)
			item["idSlot"] = novo_slot
			inventario.append(item)
			houve_movimento = true
			break


# Ordena a lista por slot e avisa a interface que houve alteracao.
func _emitir_atualizacao() -> void:
	inventario.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("idSlot", 0)) < int(b.get("idSlot", 0))
	)
	inventario_atualizado.emit()


func _solicitar_salvamento() -> void:
	if SaveManager.aplicando_save:
		return
	SaveManager.solicitar_salvamento()
