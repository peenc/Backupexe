extends Node2D

@export var tamanho_bloco: Vector2 = Vector2(1136, 656) # tamanho de cada bloco (em pixels)
@export var alcance_blocos: int = 2 # quantos blocos para cada lado do player
@export var cena_tilemap: PackedScene = preload("res://Scripts/cenario_1.tscn")

@export var inimigo_scene: PackedScene
@export var player_path: NodePath
var player: Node2D
var mapa_escolhido := ""


var blocos_gerados := {} # dicionário para guardar blocos instanciados

var blocos_node: Node2D

func _ready():
	randomize()

	var opcoes_mapa = ["mapacomburaco", "Nucleo congelado"]
	mapa_escolhido = opcoes_mapa[randi() % opcoes_mapa.size()]
	print("🌍 Mapa escolhido: ", mapa_escolhido)

	player = get_node(player_path)
	
	if mapa_escolhido == "Nucleo congelado":
		player.SPEED *= 0.8
		print("❄️ Mapa frio detectado! Velocidade reduzida para:", player.SPEED)
	else:
		print("🔥 Mapa normal. Velocidade padrão do jogador:", player.SPEED)

	blocos_node = $World/Blocos
	$World/MusicaAmbiente.play()
	$World/WaveManager.iniciar_ondas()



func _process(delta):
	# Movimento do mundo baseado em input (não mexe no player diretamente aqui)
	if Input.is_action_pressed("ui_right"):
		position.x += 300 * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= 300 * delta
	if Input.is_action_pressed("ui_down"):
		position.y += 300 * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= 300 * delta
	
	Pontuacao.tempo_sobrevivido += delta
	if int(Pontuacao.tempo_sobrevivido) % 10 == 0:
		Pontuacao.pontos += 10  

	atualizar_blocos_proximos()

func get_celula_do_player() -> Vector2i:
	var pos = player.global_position
	return Vector2i(
		floor(pos.x / tamanho_bloco.x),
		floor(pos.y / tamanho_bloco.y)
	)
	
var blocos_por_frame = 4
var blocos_gerados_nesse_frame = 0
func atualizar_blocos_proximos():
	blocos_gerados_nesse_frame = 0
	var celula_atual = get_celula_do_player()

	# Criar novos blocos
	for x in range(celula_atual.x - alcance_blocos, celula_atual.x + alcance_blocos + 1):
		for y in range(celula_atual.y - alcance_blocos, celula_atual.y + alcance_blocos + 1):
			var chave = Vector2i(x, y)
			if not blocos_gerados.has(chave):
				if blocos_gerados_nesse_frame >= blocos_por_frame:
					return

				var bloco = cena_tilemap.instantiate()
				bloco.position = Vector2(x * tamanho_bloco.x, y * tamanho_bloco.y)

				# 🔥 Ativa apenas o mapa escolhido (visível)
				var todos_mapas = ["mapacomburaco", "Nucleo congelado"]
				for nome in todos_mapas:
					if bloco.has_node(nome):
						bloco.get_node(nome).visible = (nome == mapa_escolhido)

				blocos_node.add_child(bloco)
				blocos_gerados[chave] = bloco
				blocos_gerados_nesse_frame += 1

	# Remover blocos distantes
	var blocos_para_remover = []
	for chave in blocos_gerados.keys():
		var dx = abs(chave.x - celula_atual.x)
		var dy = abs(chave.y - celula_atual.y)
		if dx > alcance_blocos or dy > alcance_blocos:
			blocos_para_remover.append(chave)

	for chave in blocos_para_remover:
		var bloco = blocos_gerados[chave]
		if is_instance_valid(bloco):
			bloco.queue_free()
		blocos_gerados.erase(chave)
