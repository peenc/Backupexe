extends Node

const RANKING_PATH = "user://ranking.save"
const MAX_ENTRADAS = 5

var ranking = []

func _ready():
	carregar_ranking()

func carregar_ranking():
	if FileAccess.file_exists(RANKING_PATH):
		var file = FileAccess.open(RANKING_PATH, FileAccess.READ)
		var content = file.get_as_text()
		ranking = JSON.parse_string(content)
		if ranking == null:
			ranking = []
	else:
		ranking = []

func salvar_ranking():
	var file = FileAccess.open(RANKING_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(ranking))

func tentar_adicionar_pontuacao(nova_score: int, tempo: float):
	ranking.append({ "score": nova_score, "tempo": tempo })
	ranking.sort_custom(func(a, b): return a["score"] > b["score"])
	if ranking.size() > MAX_ENTRADAS:
		ranking = ranking.slice(0, MAX_ENTRADAS)
	salvar_ranking()

func get_ranking():
	return ranking
