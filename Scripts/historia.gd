extends Control


@export var proxima_cena: String = "res://main_menu.tscn" # caminho da cena do menu principal

@export var frases := [
	"Iniciando varredura no Setor Zero...",
	"A integridade do sistema caiu para 17%.",
	"Protocolos corrompidos. Inteligência artificial hostil detectada.",
	"Backup.exe... ativado."
]

var frase_index := 0

func _ready():
	$MusicaFundo.play()
	mostrar_frase(frase_index)

func mostrar_frase(index):
	$VBoxContainer/Label.text = frases[index]

func _input(event):
	if event.is_action_pressed("ui_accept"): # tecla Enter ou Espaço
		frase_index += 1
		if frase_index < frases.size():
			mostrar_frase(frase_index)
		else:
			get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_skip_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
