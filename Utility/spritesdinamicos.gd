extends Node2D

enum Clima { CÉU_LIMPO, VENTO, NEBLINA }

var player = null

# Area do clima
@export var area_clima: Rect2 = Rect2(Vector2(-2000, -1000), Vector2(4000, 2000))

# Configurações de clima
@export var chance_inicial_vento := 0.8
@export var chance_inicial_neblina := 0.2

@export var chance_mudar_vento := 0.4
@export var chance_mudar_neblina := 0.4

@export var intervalo_entre_mudancas := 40.0


# Parâmetros base
@export var intensidade_vento_base := 505.0
@export var gravidade_vento := 10.0
@export var densidade_vento_base := 500.0
@export var tempo_vida_vento := 3.0
@export var duracao_vento := 20.0

@export var densidade_neblina_base := 500.0
@export var tempo_vida_neblina := 10.0
@export var velocidade_neblina_base := 20.0
@export var tamanho_textura_neblina := 256  #ajustável

# Estado 
var clima_atual := Clima.CÉU_LIMPO
var timer_mudanca := 0.0
var vento_ativo := false
var neblina_ativo := false
var tempo_vento_ativo := 0.0

var particulas_vento: Array = []
var particulas_neblina: Array = []

var textura_particula: Texture2D
var textura_neblina: Texture2D

# Intensidade atual
var intensidade_vento := 0.0
var densidade_vento := 0
var densidade_neblina := 0
var velocidade_neblina := 0.0

var velocidade_original := 100

func aplicar_lentidao(player):
	if player != null and velocidade_original == null:
		velocidade_original = player.SPEED
		player.SPEED *= 0.6

func remover_lentidao(player):
	if player != null and velocidade_original != null:
		player.SPEED = velocidade_original
		velocidade_original = 0


# Inicializa as texturas e o clima inicial
func _ready():
	var player = get_tree().get_first_node_in_group("player")
	textura_particula = criar_textura_bolinha_branca(4)
	textura_neblina = criar_textura_neblina(tamanho_textura_neblina)
	inicializar_clima_inicial()

# Verifica o clima a todo tempo
func _process(delta):
	timer_mudanca -= delta

	if vento_ativo:
		processar_vento(delta)
	if neblina_ativo:
		processar_neblina(delta)

	if timer_mudanca <= 0:
		mudar_clima()
		timer_mudanca = intervalo_entre_mudancas

# ---------------------
# SISTEMA DE CLIMA
# ---------------------

# Sorteia um clima para inicializar
func inicializar_clima_inicial():
	var sorteio = randf()
	if sorteio <= chance_inicial_vento:
		ativar_vento()
	elif sorteio <= chance_inicial_vento + chance_inicial_neblina:
		ativar_neblina()
	else:
		clima_atual = Clima.CÉU_LIMPO

# Muda o clima com base em chances
func mudar_clima():
	desativar_todos_os_climas()
	var sorteio = randf()
	if sorteio <= chance_mudar_vento:
		ativar_vento()
	elif sorteio <= chance_mudar_vento + chance_mudar_neblina:
		ativar_neblina()
	else:
		clima_atual = Clima.CÉU_LIMPO

func desativar_todos_os_climas():
	desativar_vento()
	desativar_neblina()

# ---------------------
# VENTO
# ---------------------
# Ativa o vento se baseando na densidade e intensidade
func ativar_vento():
	$Wind.play()
	if player:
		aplicar_lentidao(player)
		print("aplicando lentidão no jogador")
	vento_ativo = true
	tempo_vento_ativo = 0.0
	clima_atual = Clima.VENTO
	print("VENTO COMEÇANDO")
	intensidade_vento = intensidade_vento_base * randf_range(0.7, 1.5)
	densidade_vento = int(densidade_vento_base * randf_range(0.7, 1.4))
	for i in densidade_vento:
		particulas_vento.append(criar_particula_vento())

func desativar_vento():
	if player:
		remover_lentidao(player)
		print("removendo lentidao no jogador")
	for data in particulas_vento:
		if is_instance_valid(data.sprite):
			remove_child(data.sprite)
			data.sprite.queue_free()
	particulas_vento.clear()
	vento_ativo = false
	print("VENTO ACABANDO")
	$Wind.stop()
# Cria particula de vento, posiciona e reutiliza as particulas ao fim
func processar_vento(delta):
	tempo_vento_ativo += delta
	var progresso = clamp(tempo_vento_ativo / duracao_vento, 0.0, 1.0)
	var intensidade_atual = intensidade_vento * progresso

	for i in particulas_vento.size():
		var data = particulas_vento[i]
		if not is_instance_valid(data.sprite):
			continue

		if not data.atingiu_chao:
			data.tempo_restante -= delta
			data.vel_y += gravidade_vento * delta
			data.sprite.position += Vector2(intensidade_atual * delta, data.vel_y * delta)

			if data.sprite.position.y >= area_clima.position.y + area_clima.size.y:
				data.sprite.position.y = area_clima.position.y + area_clima.size.y
				data.atingiu_chao = true
				data.vel_y = 0
		elif data.reutilizavel and data.tempo_restante <= 0:
			particulas_vento[i] = criar_particula_vento()
			remove_child(data.sprite)
			data.sprite.queue_free()

# ---------------------
# NEBLINA
# ---------------------

# Ativa neblina se baseando na densidade e velocidade
func ativar_neblina():
	neblina_ativo = true
	clima_atual = Clima.NEBLINA
	print("NEBLINA COMEÇANDO")
	densidade_neblina = int(densidade_neblina_base * randf_range(0.8, 2.0))
	velocidade_neblina = velocidade_neblina_base * randf_range(0.6, 1.3)
	for i in densidade_neblina:
		particulas_neblina.append(criar_particula_neblina())

func desativar_neblina():
	neblina_ativo = false
	for data in particulas_neblina:
		if is_instance_valid(data.sprite):
			remove_child(data.sprite)
			data.sprite.queue_free()
	particulas_neblina.clear()
	print("NEBLINA ACABANDO")

# cria as particulas e posiciona
func processar_neblina(delta):
	for data in particulas_neblina:
		if is_instance_valid(data.sprite):
			data.sprite.position.x += velocidade_neblina * delta
			data.sprite.position.y += sin(Time.get_ticks_msec() / 1000.0 + data.sprite.position.x) * delta * 4.0

			data.tempo_restante -= delta

			if (data.sprite.position.x > area_clima.position.x + area_clima.size.x + 400) or data.tempo_restante <= 0:
				data.sprite.position = gerar_posicao_neblina()
				data.tempo_restante = randf_range(tempo_vida_neblina * 0.7, tempo_vida_neblina)

# ---------------------
# PARTICULAS
# ---------------------

# cria as particulas, textura, tamanho, posicao e cor
func criar_particula_vento():
	var sprite = Sprite2D.new()
	sprite.texture = textura_particula
	sprite.scale = Vector2(0.8, 0.8)
	sprite.position = gerar_posicao_vento()
	sprite.modulate = Color(1, 1, 1, randf_range(0.4, 0.8))

	add_child(sprite)

	return {
		"sprite": sprite,
		"vel_y": 0.0,
		"atingiu_chao": false,
		"tempo_restante": randf_range(tempo_vida_vento * 0.6, tempo_vida_vento),
		"reutilizavel": true
	}
	
# Sorteada baseado na área que ela pode aparecer pode ser fora da tela ou dentro
func gerar_posicao_vento() -> Vector2:
	return Vector2(
		randf_range(area_clima.position.x, area_clima.position.x + area_clima.size.x),
		randf_range(area_clima.position.y, area_clima.position.y + area_clima.size.y * 0.5)
	)
# cria as particulas, textura, tamanho, posicao e cor
func criar_particula_neblina():
	var sprite = Sprite2D.new()
	sprite.texture = textura_neblina
	sprite.scale = Vector2(randf_range(1.0, 2.5), randf_range(0.8, 2.2))
	sprite.position = gerar_posicao_neblina()
	sprite.modulate = Color(1, 1, 1, randf_range(0.08, 0.18))

	add_child(sprite)

	return {
		"sprite": sprite,
		"tempo_restante": randf_range(tempo_vida_neblina * 0.7, tempo_vida_neblina)
	}

# Sorteada baseado na área que ela pode aparecer pode ser fora da tela ou dentro
func gerar_posicao_neblina() -> Vector2:
	var x = randf_range(area_clima.position.x - 400, area_clima.position.x + area_clima.size.x + 400)
	var y = randf_range(area_clima.position.y, area_clima.position.y + area_clima.size.y)
	return Vector2(x, y)

# ---------------------
# TEXTURAS
# ---------------------

func criar_textura_bolinha_branca(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	for x in tamanho:
		for y in tamanho:
			var dx = x - tamanho / 2
			var dy = y - tamanho / 2
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= tamanho / 2:
				img.set_pixel(x, y, Color(1, 1, 1, 1))
			else:
				img.set_pixel(x, y, Color(1, 1, 1, 0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

func criar_textura_neblina(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	var centro = tamanho / 2
	var raio = tamanho / 2

	for x in tamanho:
		for y in tamanho:
			var dx = x - centro
			var dy = y - centro
			var dist = sqrt(dx * dx + dy * dy)
			var alpha = clamp(1.0 - (dist / raio), 0.0, 1.0) * randf_range(0.3, 0.5)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))

	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)
