extends Node2D

func _ready():
	criar_particulas_explosao()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func criar_particulas_explosao():
	var particulas = GPUParticles2D.new()
	particulas.amount = 100
	particulas.lifetime = 1.0
	particulas.one_shot = true
	particulas.emitting = true
	particulas.position = Vector2.ZERO
	
	# Usa a textura de bolinha com borda criada programaticamente
	particulas.texture = criar_textura_bolinha_bordo(16)
	
	var mat = ParticleProcessMaterial.new()
	
	# Emissão em esfera para espalhar em 360 graus
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 10.0
	
	mat.spread = 360.0
	
	mat.initial_velocity_min = 150.0
	mat.initial_velocity_max = 250.0
	
	mat.damping_min = 0.1
	mat.damping_max = 0.3
	
	mat.gravity = Vector3.ZERO
	
	mat.angular_velocity_min = 1.0
	mat.angular_velocity_max = 3.0
	
	mat.scale_min = 0.05
	mat.scale_max = 0.15
	
	# Escala animada (cresce e some)
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))
	scale_curve.add_point(Vector2(0.3, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	mat.scale_curve = scale_curve
	
	# Gradiente de cor azul neon com fade
	var ramp = Gradient.new()
	ramp.add_point(0.0, Color(0.0, 1.0, 1.0, 1))  # azul neon opaco
	ramp.add_point(0.7, Color(0.0, 1.0, 1.0, 0.4))
	ramp.add_point(1.0, Color(0.0, 1.0, 1.0, 0))
	
	var color_ramp = GradientTexture1D.new()
	color_ramp.gradient = ramp
	mat.color_ramp = color_ramp
	
	particulas.process_material = mat
	
	add_child(particulas)
	
	# Remove as partículas depois que terminarem de emitir
	await get_tree().create_timer(particulas.lifetime + 0.2).timeout
	particulas.queue_free()

func criar_textura_bolinha_bordo(tamanho: int) -> Texture2D:
	var img = Image.create(tamanho, tamanho, false, Image.FORMAT_RGBA8)
	for x in tamanho:
		for y in tamanho:
			var dx = x - tamanho / 2
			var dy = y - tamanho / 2
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= tamanho / 2:
				img.set_pixel(x, y, Color(0.0, 1.0, 1.0, 1))  # azul neon
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))  # transparente
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)
