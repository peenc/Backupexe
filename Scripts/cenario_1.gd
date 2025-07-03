extends TileMapLayer

var mapa_ativo
func _ready():
	randomize()
	
func ativar_mapa_aleatorio():
	var mapas = [
		$mapacomburaco,
		$"Nucleo congelado"
	]
	for mapa in mapas:
		mapa.visible = false
	
	mapa_ativo = mapas[randi() % mapas.size()]
	mapa_ativo.visible = true
	print("Mapa ativado: ", mapa_ativo.name)


func eh_mapa_frio() -> bool:
	return mapa_ativo == $"Nucleo congelado"
