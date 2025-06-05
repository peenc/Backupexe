extends Node2D

@export var intensidade_vento := 0.5  # entre 0 (sem vento) e 1 (vento forte)
@export var area_vento := Rect2(Vector2(-100, -100), Vector2(200, 200))  # fica mais centralizado
@export var raio_vento: float = 64.0  # raio circular da habilidade


var particulas_vento: GPUParticles2D

func _ready():
	position = Vector2.ZERO  # relativo ao nó pai (habilidade)
	criar_particulas_continuas()
	await get_tree().create_timer(4).timeout

	particulas_vento.emitting = false
	criar_particulas_caidas()  # nova função
	await get_tree().create_timer(4).timeout  # tempo para ver o efeito
	queue_free()


func criar_particulas_continuas():
	particulas_vento = GPUParticles2D.new()
	particulas_vento.amount = 300 # número total de partículas simultâneas
	particulas_vento.lifetime = 5.0
	particulas_vento.emitting = true
	particulas_vento.position = area_vento.position + area_vento.size / 1.2
	particulas_vento.texture = criar_textura_bolinha_bordo(32) #preload("res://icon.svg")  
	particulas_vento.process_material = criar_material_vento()

	add_child(particulas_vento)
	
func criar_particulas_caidas():
	var particulas_caidas = GPUParticles2D.new()
	particulas_caidas.amount = 150
	particulas_caidas.lifetime = 10.0  # duram mais
	particulas_caidas.one_shot = true
	particulas_caidas.emitting = true
	particulas_caidas.position = area_vento.position + area_vento.size / 1.2
	particulas_caidas.texture = criar_textura_bolinha_bordo(32)

	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 64

	# Pouca velocidade, como se estivessem quase parando
	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 30.0

	mat.damping_min = 0.9
	mat.damping_max = 1.0

	mat.gravity = Vector3(0, 0, 0)
	mat.angular_velocity_min = 0
	mat.angular_velocity_max = 1

	mat.scale_min = 0.05
	mat.scale_max = 0.08
	mat.color = Color(0.5, 0, 0.25, 0.9)  # mesma cor da anterior

	# Sem fade-out! (elas ficam paradas visíveis)
	var ramp := Gradient.new()
	ramp.add_point(0.0, Color(0.5, 0, 0.25, 0.9))
	ramp.add_point(1.0, Color(0.5, 0, 0.25, 0.9))
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = ramp
	mat.color_ramp = color_ramp

	particulas_caidas.process_material = mat
	add_child(particulas_caidas)

func criar_material_vento() -> ParticleProcessMaterial:
	var mat = ParticleProcessMaterial.new()

	# Emissão circular
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 80  # controla o raio do espiral

	# Direção inicial + spread
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 180.0  # espalha em todas as direções para girar

	# Movimento curvo/espiralado
	mat.initial_velocity_min = 100.0 * intensidade_vento
	mat.initial_velocity_max = 180.0 * intensidade_vento

	# Gira com velocidade angular
	mat.angular_velocity_min = 8.0
	mat.angular_velocity_max = 14.0

	# Escala e opacidade
	mat.scale_min = 0.05
	mat.scale_max = 0.1
	mat.color = Color(0.5, 0, 0.25, 0.8)

	# Sem gravidade, mas com damping pra simular desaceleração
	mat.gravity = Vector3(0, 0, 0)
	mat.damping_min = 0.8
	mat.damping_max = 1.0

	# Turbulência ajuda a deixar mais orgânico
	mat.turbulence_enabled = true
	mat.turbulence_noise_strength = 0.5

	# Fade-out visual
	var ramp := Gradient.new()
	ramp.add_point(0.0, Color(0.5, 0, 0.25, 0.8))
	ramp.add_point(0.6, Color(0.5, 0, 0.25, 0.8))
	ramp.add_point(1.0, Color(0.5, 0, 0.25, 0.0))

	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = ramp
	mat.color_ramp = color_ramp

	return mat


func criar_textura_bolinha_bordo(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	
	for x in tamanho:
		for y in tamanho:
			var dx = x - tamanho / 2
			var dy = y - tamanho / 2
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= tamanho / 2:
				img.set_pixel(x, y, Color(0.5, 0, 0.25, 1))  # cor vinho
			else:
				img.set_pixel(x, y, Color(1, 1, 1, 0))  # transparente
	
	img.generate_mipmaps()  # melhora o visual quando redimensionado
	
	var tex = ImageTexture.create_from_image(img)
	return tex
