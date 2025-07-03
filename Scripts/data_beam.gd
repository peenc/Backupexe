extends Node2D

@export var beam_duration := 5
@export var dano_por_tick := 2
@export var intervalo_dano := 1
@export var explosao_particula_scene: PackedScene
@export var dano_base_skill := 1
@export var multiplicador := 1.0

@onready var start_circle = $AnimatedSprite2D
@onready var impact_particles = $ImpactParticles
@onready var damage_area = $DamageArea
@onready var collision_shape = $DamageArea/CollisionShape2D

var player
var ativo = false
var tempo_ativo = 0.0
var inimigos_afetados := {}

func _ready():
	damage_area.connect("body_entered", Callable(self, "_on_body_entered"))
	damage_area.connect("body_exited", Callable(self, "_on_body_exited"))

	start_circle.visible = false
	impact_particles.emitting = false
	damage_area.monitoring = false

	# Centraliza a área de colisão no DamageArea
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(100, 20)  # Comprimento e grossura do feixe
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, 0)

	# Debug visual opcional
	#var debug_rect = ColorRect.new()
	#debug_rect.color = Color(1, 0, 0, 0.3)
	#debug_rect.size = shape.extents * 2
	#debug_rect.position = -shape.extents
	#w damage_area.add_child(debug_rect)

	call_deferred("loop_dano")

func ativar_databeam():
	$LaserBeamSound.play()
	if not ativo:
		ativo = true
		tempo_ativo = beam_duration

		start_circle.visible = true
		start_circle.play("default")
		impact_particles.emitting = true
		damage_area.monitoring = true

func _process(delta):
	if not is_instance_valid(player):
		return

	# A base do feixe sempre fica no jogador
	global_position = player.global_position

	# Rotaciona o feixe para apontar para o mouse
	var dir = (get_global_mouse_position() - global_position).normalized()
	rotation = dir.angle()

	# A área de dano fica à frente do feixe (200 pixels à frente)
	damage_area.position = Vector2(150, 0)  # 150px na frente do centro do feixe
	damage_area.rotation = 0  # Sempre reto, pois o pai (feixe) já está rotacionado

	if ativo:
		tempo_ativo -= delta
		if tempo_ativo <= 0:
			_desativar_databeam()

func _desativar_databeam():
	$LaserBeamSound.stop()
	ativo = false
	start_circle.visible = false
	start_circle.stop()
	impact_particles.emitting = false
	damage_area.monitoring = false
	inimigos_afetados.clear()

func _on_body_entered(body):
	if body.is_in_group("inimigo"):
		inimigos_afetados[body] = true

func _on_body_exited(body):
	inimigos_afetados.erase(body)

func loop_dano():
	while is_inside_tree():
		if ativo:
			for inimigo in inimigos_afetados.keys():
				if not is_instance_valid(inimigo):
					inimigos_afetados.erase(inimigo)
					continue
				if inimigo.has_method("receber_dano"):
					inimigo.receber_dano(dano_por_tick)
				if explosao_particula_scene:
					var explosao = explosao_particula_scene.instantiate()
					explosao.global_position = inimigo.global_position
					get_tree().current_scene.add_child(explosao)
		await get_tree().create_timer(intervalo_dano).timeout

func aplicar_upgrade(nivel: int, dano_jogador: float):
	match nivel:
		1:
			dano_base_skill = 2
			multiplicador = 1.0
		2:
			dano_base_skill = 2.5
			multiplicador = 1.2
		3:
			dano_base_skill = 3
			multiplicador = 1.5

	dano_por_tick = (dano_jogador + dano_base_skill) * multiplicador
