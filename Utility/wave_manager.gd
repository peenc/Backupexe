extends Node

@export var inimigo_cena: PackedScene
@export var inimigo_atirador_cena: PackedScene
@export var boss_cena: PackedScene  # <- Adicione isso no inspetor
@export var tempo_entre_ondas: float = 20.0
@export var minimo_inimigos_para_nova_onda: int = 3  # quando só sobrar 3 inimigos, próxima onda

var onda_atual := 0
var player: Node2D
var inimigos_vivos := []  # armazena os inimigos vivos

func _ready():
	self.process_mode = Node.PROCESS_MODE_PAUSABLE
	await get_tree().process_frame  # espera 1 frame pra garantir que a cena carregou
	
	iniciar_ondas()


func iniciar_ondas():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("❌ Player não encontrado no grupo 'player'")
		return
	await iniciar_onda()



func iniciar_onda():
	onda_atual += 1
	print("🌊 Iniciando Onda ", onda_atual)

	var qtd_inimigos = 5 + onda_atual * 2
	for i in range(qtd_inimigos):
		# Sorteia tipo de inimigo: 0 = normal, 1 = atirador
		var tipo = randi() % 2
		var inimigo

		if tipo == 0:
			inimigo = inimigo_cena.instantiate()
		else:
			inimigo = inimigo_atirador_cena.instantiate()

		inimigo.global_position = gerar_posicao_fora_da_tela(player.global_position, 800, 1200)
		inimigo.SPEED += onda_atual * 2
		inimigo.hp += onda_atual * 2
		inimigo.player = player

		inimigo.connect("inimigo_morreu", Callable(self, "_on_inimigo_morreu"))
		inimigos_vivos.append(inimigo)
		add_child(inimigo)


	if onda_atual % 5 == 0:
		var boss = boss_cena.instantiate()
		boss.global_position = gerar_posicao_fora_da_tela(player.global_position, 1000, 1400)
		boss.SPEED += onda_atual
		boss.hp += onda_atual * 20
		boss.experience += onda_atual * 5
		boss.player = player

		boss.connect("inimigo_morreu", Callable(self, "_on_inimigo_morreu"))
		inimigos_vivos.append(boss)
		add_child(boss)
		print("⚠️ Boss apareceu na onda ", onda_atual)

	# Aguarda tempo OU morte de inimigos
	await esperar_proxima_onda()

func esperar_proxima_onda():
	var tempo = 0.0
	while tempo < tempo_entre_ondas:
		await get_tree().create_timer(0.5).timeout
		tempo += 0.5

		# Se restarem poucos inimigos, já pode iniciar nova onda
		if inimigos_vivos.size() <= minimo_inimigos_para_nova_onda:
			break

	await iniciar_onda()

func _on_inimigo_morreu(inimigo):
	inimigos_vivos.erase(inimigo)

func gerar_posicao_fora_da_tela(player_pos: Vector2, distancia_min: float, distancia_max: float) -> Vector2:
	var angulo = randf_range(0, TAU)
	var distancia = randf_range(distancia_min, distancia_max)
	var offset = Vector2.RIGHT.rotated(angulo) * distancia
	return player_pos + offset
