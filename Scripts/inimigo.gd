extends CharacterBody2D

@export var SPEED := 50
@export var player_path : NodePath  
@export var hp = 2
@export var player : Node2D
@export var experience = 1
var sprite: Sprite2D
var velocidade_original := SPEED
var slow_factor := 1.0  # Reduz a velocidade quando leva slow

@onready var loot_base = get_tree().get_first_node_in_group("loot")

var exp_gem = preload("res://Objects/xpcomum.tscn")

func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	sprite = $Sprite2D
	add_to_group("inimigo")

func _physics_process(delta: float) -> void:
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED * slow_factor
	move_and_slide()

	# Espelhar o sprite baseado na posição relativa do jogador
	if direction.x != 0:
		sprite.flip_h = direction.x > 0

func receber_dano(dano: int) -> void:
	hp -= dano
	#print("Inimigo tomou dano! HP: ", hp)
	piscar_dano()
	if hp <= 0:
		die()

func piscar_dano():
	var sprite = $Sprite2D
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

var particulasmorte = preload("res://Scripts/particulaseliminacao.tscn")

signal inimigo_morreu


func die():	
	Pontuacao.inimigos_derrotados += 1
	Pontuacao.pontos += 100

	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	emit_signal("inimigo_morreu", self)
	desaparecer_e_morrer()

func desaparecer_e_morrer():
	desativar_inimigo()

	if not is_inside_tree():
		return

	var particula = particulasmorte.instantiate()
	particula.global_position = global_position


	if get_parent():
		get_parent().add_child(particula)

	# Começa o fade-out
	var tempo = 0.5  # segundos para desaparecer
	var t = 0.0

	while t < tempo:
		if not is_inside_tree():
			return  # Se a árvore foi destruída, interrompe o fade
		t += get_process_delta_time()
		modulate.a = lerp(1.0, 0.0, t / tempo)  # reduz alpha de 1 para 0
		await get_tree().process_frame

	# Depois do fade, remove o inimigo
	if is_inside_tree():
		queue_free()

	
func desativar_inimigo():
	$CollisionShape2D.disabled = true
	$hitboxInimigo.set_deferred("disabled", true)
	$hurtboxinimigo.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)


# === SLOW ===
func aplicar_slow(percentual: float):
	slow_factor = clamp(1.0 - percentual, 0.1, 1.0)

func remover_slow():
	slow_factor = 1.0

# === COLISÃO COM ÁREAS DO JOGADOR (opcional) ===
func _on_hurtboxinimigo_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var dano = area.damage
		receber_dano(dano)
