extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

@export var nivel := 1
@export var hp := 1
@export var velocidade := 100.0
@export var dano := 5
@export var knock_amount := 100
@export var tamanho_ataque := 1.0
@export var source_group := ""

var direcao = Vector2.ZERO
var target = Vector2.ZERO
var angle := 0.0
@export var raio := 50.0  # Distância do jogador
@export var rotacao_velocidade := 2.0  # Velocidade angular

var angulo := 0.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("hitbox")
	source_group = "player"
	scale = Vector2.ONE * tamanho_ataque
	set_physics_process(false)  # Agora quem controla é o player



func _physics_process(delta):
	if player:
		angulo += rotacao_velocidade * delta
		var offset = Vector2.RIGHT.rotated(angulo) * raio
		global_position = player.global_position + offset

func hit_inimigo(charge := 1):
	# Não faça nada aqui para que a skill não suma nem tome dano
	pass


func _on_timer_timeout() -> void:
	pass # Replace with function body.


func _on_body_entered(body):
	if body.is_in_group(source_group):
		return

	if body.has_method("receber_dano"):
		body.receber_dano(dano)

	hit_inimigo()
