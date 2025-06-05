extends CharacterBody2D

@export var SPEED := 80
@export var player_path : NodePath
@export var hp = 100
@export var player : Node2D
@export var experience = 30
@export var hp_por_fase = 50
@export var tempo_invulneravel = 5.0
@export var dano_do_ataque = 10
# === DASH CONFIG ===
@export var dash_speed := 500       # Velocidade durante o dash
@export var dash_cooldown := 5.0    # Tempo entre os dashes
@export var dash_duration := 0.5     # Duração do dash
@export var detection_radius := 400  # Raio para detectar o player e iniciar dash

var pode_dar_dash = true
var esta_dando_dash = false

# === OUTRAS VARIÁVEIS ===
var hp_ultimo_checkpoint = 0
var invulneravel = false

var velocidade_original := SPEED
var slow_factor := 1.0

var atacando = false
var tomando_dano = false
var direction = Vector2.ZERO

var morto = false
var alvo_no_alcance = false

@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox

var exp_gem = preload("res://Objects/xpcomum.tscn")
var particulasmorte = preload("res://particulaseliminacao.tscn")

func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	add_to_group("inimigo")
	sprite.play("Andando")


func _physics_process(_delta: float) -> void:
	if morto or not player or atacando or tomando_dano:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Dash
	tentar_dar_dash()

	# Movimento normal
	direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED * slow_factor
	move_and_slide()

	# Espelhar sprite e hitbox
	atualizar_espelhamento()

	# Animação andando
	if velocity.length() > 1:
		if sprite.animation != "Andando":
			sprite.play("Andando")


func atualizar_espelhamento():
	if direction.x != 0:
		var olhando_direita = direction.x > 0
		sprite.flip_h = not olhando_direita  # Se sua sprite olha para esquerda

		hitbox.position.x = abs(hitbox.position.x) * (1 if olhando_direita else -1)
		hurtbox.position.x = abs(hurtbox.position.x) * (1 if olhando_direita else -1)

var tempo_impacto_ataque = 1.0
# === ATAQUE ===
func atacar():
	if atacando:
		return

	atacando = true
	velocity = Vector2.ZERO
	hitbox.set_deferred("disabled", true)  # Desativa hitbox durante o ataque

	sprite.play("Ataque")

	await get_tree().create_timer(tempo_impacto_ataque).timeout
	if alvo_no_alcance:
		aplicar_dano_no_player()

	await sprite.animation_finished

	hitbox.set_deferred("disabled", false)  # Reativa hitbox depois
	atacando = false


func aplicar_dano_no_player():
	if alvo_no_alcance and not morto and is_instance_valid(player):
		player.take_damage(dano_do_ataque)

# === DANO ===
func receber_dano(dano: int) -> void:
	if invulneravel or tomando_dano or atacando:
		return

	hp -= dano
	tomando_dano = true
	piscar_dano()
	tomando_dano = false

	if (hp_ultimo_checkpoint - hp) >= hp_por_fase:
		hp_ultimo_checkpoint = hp
		ativar_invulnerabilidade()

	if hp <= 0:
		die()
	elif not atacando:
		sprite.play("Andando")


func ativar_invulnerabilidade():
	invulneravel = true
	modulate = Color(0.5, 0.5, 1)  # Azul invulnerável
	$CollisionShape2D.disabled = true
	hurtbox.set_deferred("disabled", true)

	await get_tree().create_timer(tempo_invulneravel).timeout

	invulneravel = false
	modulate = Color(1, 1, 1)  # Volta ao normal
	$CollisionShape2D.disabled = false
	hurtbox.set_deferred("disabled", false)


func piscar_dano():
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)


# === MORTE ===
func die():
	if morto:
		return
	morto = true

	velocity = Vector2.ZERO
	desativar_inimigo()

	sprite.play("Morte")
	var particula = particulasmorte.instantiate()
	particula.global_position = global_position
	get_parent().add_child(particula)

	await get_tree().create_timer(1.8).timeout

	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)

	await get_tree().create_timer(0.5).timeout

	queue_free()


func desativar_inimigo():
	$CollisionShape2D.disabled = true
	hitbox.set_deferred("disabled", true)
	hurtbox.set_deferred("disabled", true)

	set_process(false)
	set_physics_process(false)


# === SLOW ===
func aplicar_slow(percentual: float):
	slow_factor = clamp(1.0 - percentual, 0.1, 1.0)


func remover_slow():
	slow_factor = 1.0

# === DASH ===
var dash_target_position = Vector2.ZERO

func tentar_dar_dash():
	if pode_dar_dash and not esta_dando_dash and not atacando:
		var distancia_ate_player = global_position.distance_to(player.global_position)
		if distancia_ate_player <= detection_radius:
			dash_target_position = player.global_position
			preparar_dash()

func preparar_dash():
	esta_dando_dash = true
	pode_dar_dash = false
	SPEED = 0
	# Pisca em vermelho como aviso
	sprite.play("Buff")
	await get_tree().create_timer(1.5).timeout  # Delay antes do dash
	
	executar_dash()
	SPEED = 80

func executar_dash():
	# Verifica se ainda existe
	if morto or not is_instance_valid(self):
		return

	$CollisionShape2D.disabled = true
	if player == null or not is_instance_valid(player):
		$CollisionShape2D.disabled = false
		return

	esta_dando_dash = true
	pode_dar_dash = false

	# Efeito visual
	modulate = Color(1, 0.7, 0.7)

	var dash_direction = (dash_target_position - global_position).normalized()

	if dash_direction == Vector2.ZERO:
		esta_dando_dash = false
		modulate = Color(1, 1, 1)
		$CollisionShape2D.disabled = false
		return

	var dash_timer = dash_duration

	while dash_timer > 0:
		# Checa se ainda existe
		if morto or not is_instance_valid(self) or not is_inside_tree():
			return
		if player == null or not is_instance_valid(player):
			break

		var delta = get_physics_process_delta_time()
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		move_and_slide()

		await get_tree().process_frame

		if morto or not is_instance_valid(self) or not is_inside_tree():
			return

	velocity = Vector2.ZERO
	esta_dando_dash = false
	modulate = Color(1, 1, 1)

	if morto or not is_instance_valid(self) or not is_inside_tree():
		return

	$CollisionShape2D.disabled = false

	await get_tree().create_timer(dash_cooldown).timeout

	if not morto and is_instance_valid(self) and is_inside_tree():
		pode_dar_dash = true



# === COLISÕES ===
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var dano = area.damage
		receber_dano(dano)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		alvo_no_alcance = true
		# Só inicia o ataque, mas não aplica dano aqui
		if not atacando:
			atacar()


func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		alvo_no_alcance = false
		atacando = false
		if hp > 0:
			sprite.play("Andando")


func _on_animated_sprite_2d_animation_finished() -> void:
	pass
