extends Node2D

@export var intensidade_vento := 0.5  # entre 0 (sem vento) e 1 (vento forte)
@export var area_vento := Rect2(Vector2(-3000, -2000), Vector2(5000, 3000))

var particulas_vento: GPUParticles2D

func _ready():
	criar_particulas_continuas()

func criar_particulas_continuas():
	particulas_vento = GPUParticles2D.new()
	particulas_vento.amount = 15000 # número total de partículas simultâneas
	particulas_vento.lifetime = 5.0
	particulas_vento.emitting = true
	particulas_vento.position = area_vento.position + area_vento.size / 2
	particulas_vento.texture = criar_textura_bolinha_branca(32) #preload("res://icon.svg")  # ou outra textura visível
	particulas_vento.process_material = criar_material_vento()

	add_child(particulas_vento)
	
func criar_material_vento() -> ParticleProcessMaterial:
	var mat = ParticleProcessMaterial.new()

	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(2500, 1500, 0) 

	mat.initial_velocity_min = 100.0 * intensidade_vento
	mat.initial_velocity_max = 180.0 * intensidade_vento
	mat.direction = Vector3(2, 1, 0)  # vento da esquerda pra direita
	mat.spread = 20.0  # um pouco mais disperso

	# Simula "queda" visual no top-down: partícula vai desacelerando
	mat.gravity = Vector3(0, 0, 0)  # sem gravidade no top-down
	mat.damping_min = 0.9
	mat.damping_max = 1.0  # praticamente para de se mover

	mat.angle_min = -10.0
	mat.angle_max = 10.0
	mat.angular_velocity_min = -0.4
	mat.angular_velocity_max = 0.4
	mat.scale_min = 0.08
	mat.scale_max = 0.1
	mat.color = Color(1, 1, 1, 0.8)

	mat.turbulence_enabled = true
	mat.turbulence_noise_strength = 0.4

	# FADE OUT no final da vida
	var ramp := Gradient.new()
	ramp.add_point(0.0, Color(1, 1, 1, 0.8))   # opaco
	ramp.add_point(0.6, Color(1, 1, 1, 0.8))   # mantém opacidade
	ramp.add_point(1.0, Color(1, 1, 1, 0.0))   # desaparece

	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = ramp
	mat.color_ramp = color_ramp

	return mat


func criar_textura_bolinha_branca(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	
	for x in tamanho:
		for y in tamanho:
			var dx = x - tamanho / 2
			var dy = y - tamanho / 2
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= tamanho / 2:
				img.set_pixel(x, y, Color(1, 1, 1, 1))  # branco opaco
			else:
				img.set_pixel(x, y, Color(1, 1, 1, 0))  # transparente
	
	img.generate_mipmaps()  # melhora o visual quando redimensionado
	
	var tex = ImageTexture.create_from_image(img)
	return tex
