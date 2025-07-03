extends Control

@onready var pontuacaofinal = get_node("%PontuacaoFinal")

func _on_reiniciar_pressed() -> void:
	Pontuacao.resetar()
	get_tree().change_scene_to_file("res://world_main.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()

func _ready():
	pontuacaofinal.text = "Você fez %d pontos!\nInimigos: %d\nBosses: %d\nTempo: %.1f segundos" % [
		Pontuacao.pontos,
		Pontuacao.inimigos_derrotados,
		Pontuacao.bosses_derrotados,
		Pontuacao.tempo_sobrevivido
		]
	Ranking.tentar_adicionar_pontuacao(Pontuacao.pontos,Pontuacao.tempo_sobrevivido)

	
func _on_menu_principal_pressed() -> void:
	Pontuacao.resetar()
	get_tree().change_scene_to_file("res://main_menu.tscn")
