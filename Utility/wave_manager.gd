extends Node

@export var inimigo_cena: PackedScene
@export var boss_cena: PackedScene  # <- Adicione isso no inspetor
@export var tempo_entre_ondas: float = 20.0

var onda_atual := 0
var player: Node2D

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_PAUSABLE
	
func iniciar_ondas(player_node):
	player = player_node
	iniciar_onda()

func iniciar_onda():
	onda_atual += 1
	print("Iniciando Onda ", onda_atual)

	# Spawn dos inimigos comuns
	var qtd_inimigos = 5 + onda_atual * 2
	for i in range(qtd_inimigos):
		var inimigo = inimigo_cena.instantiate()

		var pos = gerar_posicao_fora_da_tela(player.global_position, 800, 1200)
		inimigo.global_position = pos

		inimigo.SPEED += onda_atual * 2
		inimigo.hp += onda_atual * 5
		inimigo.player = player

		add_child(inimigo)

	# Spawn do boss a cada 5 ondas
	if onda_atual % 5 == 0:
		var boss = boss_cena.instantiate()

		var pos_boss = gerar_posicao_fora_da_tela(player.global_position, 1000, 1400)
		boss.global_position = pos_boss

		# Escala o boss conforme a onda (opcional)
		boss.SPEED += onda_atual  # Boss cresce menos em velocidade
		boss.hp += onda_atual * 20  # Mais vida que inimigos comuns
		boss.experience += onda_atual * 5  # Mais XP

		boss.player = player

		add_child(boss)
		print("⚠️ Boss apareceu na onda ", onda_atual)

	await get_tree().create_timer(tempo_entre_ondas, true).timeout

	iniciar_onda()

func gerar_posicao_fora_da_tela(player_pos: Vector2, distancia_min: float, distancia_max: float) -> Vector2:
	var angulo = randf_range(0, TAU)  # TAU = 2 * PI
	var distancia = randf_range(distancia_min, distancia_max)
	var offset = Vector2.RIGHT.rotated(angulo) * distancia
	return player_pos + offset
