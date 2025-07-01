extends StaticBody3D

var occupied = false # VE SE O SOLO JA TEM UMA PLANTA (1 PLATA POR SOLO)
var crop: Node = null # REFERENCIA A PLANTA DESSE SOLO
var fertilized = false # CHECA SE JA FERTILIZOU NESTE DIA

func update_prompt_text(): # INTERFACE DO JOGO
	if !fertilized: 
		return "Aperte F para Fertilizar "
	else: 
		if !occupied:
			return "Botao Direito do Mouse Para Plantar"
		return ""
