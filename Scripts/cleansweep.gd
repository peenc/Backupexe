extends Area2D

@export var dano_base_skill := 10
@export var multiplicador := 1.0
@export var duracao := 2.2
@export var nivel := 1

var dano := 0
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$Explosion.play()
	$AnimatedSprite2D.play("explosion")
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_anim_finished"))

	var timer = Timer.new()
	timer.wait_time = duracao
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "queue_free"))

func _on_anim_finished():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("inimigo"):
		if body.has_method("receber_dano"):
			body.receber_dano(dano)

func aplicar_upgrade(nivel: int, dano_jogador: float):
	match nivel:
		1:
			dano_base_skill = 12
			multiplicador = 1.0
		2:
			dano_base_skill = 13
			multiplicador = 1.3
		3:
			dano_base_skill = 15
			multiplicador = 1.7

	dano = (dano_jogador + dano_base_skill) * multiplicador
