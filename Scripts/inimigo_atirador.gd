extends CharacterBody2D

@export var SPEED := 50
@export var player : Node2D
@export var hp := 2
@export var experience := 5
@export var distancia_min_ataque := 250.0
@export var ataque_cooldown := 2.0
@export var projetil_scene: PackedScene

var pode_atacar := true
var esta_morto := false
var direcao := Vector2.ZERO

@onready var sprite := $AnimatedSprite2D
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var hitbox := $Hitbox
@onready var hurtbox := $Hurtbox

var cooldown_timer: Timer
var exp_gem = preload("res://Objects/xpcomum.tscn")

func _ready():
	add_to_group("inimigo")
	
	cooldown_timer = Timer.new()
	cooldown_timer.name = "AttackCooldown"
	cooldown_timer.wait_time = ataque_cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_fim"))

	sprite.play("andar")


func _physics_process(delta):
	if esta_morto or not player:
		return

	direcao = (player.global_position - global_position).normalized()
	var distancia = global_position.distance_to(player.global_position)

	sprite.flip_h = direcao.x < 0

	if distancia > distancia_min_ataque:
		velocity = direcao * SPEED
		move_and_slide()
		if not sprite.is_playing() or sprite.animation != "andar":
			sprite.play("andar")
	else:
		velocity = Vector2.ZERO
		move_and_slide()

		if pode_atacar:
			atacar()


func atacar():
	pode_atacar = false
	sprite.play("atacar")

	await get_tree().create_timer(1).timeout
	if esta_morto:
		return

	var projetil = projetil_scene.instantiate()
	projetil.global_position = global_position
	projetil.direcao = (player.global_position - global_position).normalized()
	get_parent().add_child(projetil)
	print("inimigo atacando")
	cooldown_timer.start()


func _on_cooldown_fim():
	pode_atacar = true


func receber_dano(dano: int):
	if esta_morto:
		return

	hp -= dano
	piscar_dano()

	if hp <= 0:
		die()


func piscar_dano():
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)


signal inimigo_morreu

func die():
	if esta_morto:
		return

	esta_morto = true
	emit_signal("inimigo_morreu", self)
	velocity = Vector2.ZERO
	desativar_inimigo()
	Pontuacao.inimigos_derrotados += 1
	Pontuacao.pontos += 100 


	sprite.play("morrer")
	await get_tree().create_timer(1).timeout

	var gem = exp_gem.instantiate()
	gem.global_position = global_position
	gem.experience = experience
	loot_base.call_deferred("add_child", gem)

	await get_tree().create_timer(0.5).timeout
	queue_free()


func desativar_inimigo():
	$CollisionShape2D.disabled = true
#	hurtbox.set_deferred("disabled", true)
#	hitbox.set_deferred("disable", true)
	set_process(false)
	set_physics_process(false)
