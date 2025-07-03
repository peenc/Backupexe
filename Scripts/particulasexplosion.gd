extends Node2D

@export var intensidade_vento := 0.5
@export var area_vento := Rect2(Vector2(-100, -100), Vector2(200, 200))
@export var raio_vento: float = 128.0  # Aumentei pra espalhar mais

var particulas_vento: GPUParticles2D

func _ready():
	position = Vector2.ZERO
	criar_particulas()
	await get_tree().create_timer(2).timeout  # tempo de vida reduzido
	queue_free()

func criar_particulas():
	var particulas = GPUParticles2D.new()
	particulas.amount = 600
	particulas.lifetime = 2.8
	particulas.one_shot = true
	particulas.emitting = true
	particulas.position = Vector2.ZERO
	particulas.texture = criar_textura_bolinha(32)

	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 150.0  # raio maior = espalhamento maior

	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 100
	mat.initial_velocity_max = 220

	mat.gravity = Vector3(0, 0, 0)
	mat.scale_min = 0.03
	mat.scale_max = 0.08
	mat.color = Color(0.6, 0.2, 1.0, 1.0)
	mat.damping_min = 0.85
	mat.damping_max = 1.0
	mat.angular_velocity_min = 1.0
	mat.angular_velocity_max = 2.0

	var ramp = Gradient.new()
	ramp.add_point(0.0, Color(0.8, 0.2, 1.0, 1.0))
	ramp.add_point(0.5, Color(0.5, 0.0, 1.0, 0.8))
	ramp.add_point(1.0, Color(0.3, 0.0, 0.5, 0.0))

	var gradient = GradientTexture1D.new()
	gradient.gradient = ramp
	mat.color_ramp = gradient

	particulas.process_material = mat
	add_child(particulas)


func criar_textura_bolinha(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	for x in tamanho:
		for y in tamanho:
			var dx = x - tamanho / 2
			var dy = y - tamanho / 2
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= tamanho / 2:
				img.set_pixel(x, y, Color(0.8, 0.2, 1, 1))  # roxo
			else:
				img.set_pixel(x, y, Color(1, 1, 1, 0))  # transparente
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)
