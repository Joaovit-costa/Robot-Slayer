extends Node
class_name ListaItens

var itens := [
	{
		"nome": "Lume mod",
		"tipo": "equipavel",
		"quantidade": 1,
		"descricao": "Chip que aumenta o dano e deixa o inimigo queimando",
		"buffs": {
			"ataque_percentual": 10,
			"efeito": "fogo",
			"dps": 1.5,
			"duracao": 2
		},
		"link": "arma"
	},
	{
		"nome": "Volt mod",
		"tipo": "equipavel",
		"quantidade": 1,
		"descricao": "Chip elétrico que conecta dano entre inimigos próximos",
	"buffs": {
		"velocidade_ataque_percentual": 10,
		"efeito": "eletrico",
		"dano_conectado": true
	},
	"link": "arma"
	},
	{
	"nome": "White Hat mod",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Chip que aplica veneno contínuo e aumenta a inteligência",
	"buffs": {
		"inteligencia_percentual": 10,
		"efeito": "veneno",
		"dps": 0.5,
		"duracao": -1
	},
	"link": "arma"
	},
	{
	"nome": "Vitreo mod",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Chip que aumenta defesa e pode congelar inimigos",
	"buffs": {
		"defesa_percentual": 10,
		"efeito": "congelamento",
		"duracao": 1
	},
	"link": "arma"
	},
	{
	"nome": "Pyromancer",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta ataque e concede imunidade a fogo",
	"buffs": {
		"ataque_percentual": 10,
		"imunidade": "fogo",
		"dano_extra": "glacial"
	},
	"link": "player"
	},
	{
	"nome": "Pyromancer",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta ataque e concede imunidade a fogo",
	"buffs": {
		"ataque_percentual": 10,
		"imunidade": "fogo",
		"dano_extra": "glacial"
	},
	"link": "player"
	},	
	{
	"nome": "Engineer",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta velocidade e DPS",
	"buffs": {
		"velocidade_percentual": 10,
		"dps_percentual": 10
	},
	"link": "player"
	},
	{
	"nome": "Umbrella",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta inteligência e imunidade a vírus",
	"buffs": {
		"inteligencia_percentual": 10,
		"imunidade": "virus",
		"dano_extra": "malware"
	},
	"link": "player"
	},
	{
	"nome": "Umbrella",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta inteligência e imunidade a vírus",
	"buffs": {
		"inteligencia_percentual": 10,
		"imunidade": "virus",
		"dano_extra": "malware"
	},
	"link": "player"
	},
	{
	"nome": "Heater",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta defesa e imunidade ao congelamento",
	"buffs": {
		"defesa_percentual": 10,
		"imunidade": "congelamento",
		"dano_extra": "eletronico"
	},
	"link": "player"
	},
	{
	"nome": "Eile",
	"tipo": "equipavel",
	"quantidade": 1,
	"descricao": "Equipamento que aumenta velocidade de movimento",
	"buffs": {
		"velocidade_percentual": 15,
		"movimento_percentual": 15
	},
	"link": "player"
	}
] 
	
