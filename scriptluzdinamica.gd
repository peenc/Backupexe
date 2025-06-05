extends Node2D

@export var quantidade_luzes := 3
@export var area_min := Vector2(-3000, -2000)
@export var area_max := Vector2(3000, 2000)
@export var distancia_remocao := 3100.0
var luzes_ativas := []

# verifica todo momento as luzes q estao longe do personagem
func _process(delta):
	verificar_e_remover_luzes_distantes()

var cores_neon = [
	Color(0.0, 1.0, 1.0),   # Ciano
	Color(1.0, 0.0, 1.0),   # Magenta
	Color(0.0, 1.0, 0.0),   # Verde
	Color(1.0, 1.0, 0.0),   # Amarelo
	Color(0.0, 0.5, 1.0),   # Azul elétrico
	Color(1.0, 0.4, 0.7),   # Rosa neon
	Color(0.3, 1.0, 0.7),   # Verde água neon
]

# cria luz de forma aleatoria ao iniciar o cenario
func _ready():
	
	for i in quantidade_luzes:
		criar_luz_aleatoria()

@export var distancia_minima := 1500.0
var posicoes_geradas = []

# cria luz de forma aleatoria baseada na area maxima e minima definida
func criar_luz_aleatoria():
	var nova_posicao: Vector2
	var tentativa := 0
	while tentativa < 100:
		nova_posicao = Vector2(
			randf_range(area_min.x, area_max.x),
			randf_range(area_min.y, area_max.y)
		)
		var longe := true
		for pos in posicoes_geradas:
			if pos.distance_to(nova_posicao) < distancia_minima:
				longe = false
				break
		if longe:
			break
		tentativa += 1
	
	if tentativa >= 100:
		print("Não foi possível gerar posição suficientemente longe.")
		return

	posicoes_geradas.append(nova_posicao)
	
	# ponto de luz gerado
	var luz = PointLight2D.new()
	luz.position = nova_posicao
	luz.energy = randf_range(0.1, 0.5)
	luz.color = cores_neon.pick_random()
	luz.texture = preload("res://Textures/light.png")
	luz.shadow_enabled = true

	# Sprite emissor da luz
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://Textures/spot.png")
	sprite.modulate = luz.color
	sprite.centered = true
	sprite.scale = Vector2(0.3, 0.3)
	sprite.position = Vector2.ZERO

	luz.add_child(sprite)
	add_child(luz)
	luzes_ativas.append(luz)


	#var script = preload("res://oscilador.gd")
	#luz.set_script(script)

# verifica a posicao da luz refente ao jogador e remove caso esteja fora da distancia minima
func verificar_e_remover_luzes_distantes():
	if not get_tree().get_first_node_in_group("player"):
		return

	var player_pos = get_tree().get_first_node_in_group("player").global_position
	var luzes_para_remover = []

	for luz in luzes_ativas:
		if not is_instance_valid(luz):
			continue
		if luz.global_position.distance_to(player_pos) > distancia_remocao:
			luzes_para_remover.append(luz)

	for luz in luzes_para_remover:
		luzes_ativas.erase(luz)
		luz.queue_free()
