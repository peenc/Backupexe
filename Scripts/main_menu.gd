extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://world_main.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()

func _on_button_3_pressed() -> void:
	$"Ranking Menu".visible = true

func _on_button_4_pressed() -> void:
	$Tutorial.visible = true

	
func _ready():
	var lista = Ranking.get_ranking()
	var texto := ""
	for i in lista.size():
		var item = lista[i]
		texto += str(i + 1) + "º - Pontos: " + str(item["score"]) + " | Tempo: " + str(round(item["tempo"])) + "s\n"
	
	$"Ranking Menu/VBoxContainer/Label".text = texto


func _on_fechar_ranking_pressed() -> void:
	$"Ranking Menu".visible = false


func _on_fechar_tutorial_pressed() -> void:
	$Tutorial.visible = false
