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

func _ready():
	$Shoot.play()
	connect("area_entered", Callable(self, "_on_area_entered"))
	add_to_group("hitbox")
	scale = Vector2.ONE * tamanho_ataque
	source_group = "player"
	if target != Vector2.ZERO and target != global_position:
		direcao = global_position.direction_to(target)
	else:
		direcao = Vector2.RIGHT

	rotation = direcao.angle()

var quantidade_tiros = 1

func _physics_process(delta):
	position += direcao * velocidade * delta

func hit_inimigo(charge := 1):
	hp -= charge
	if hp <= 0:
		queue_free()

func _on_body_entered(body):
	#print("Colidiu com:", body.name)
	if body.is_in_group(source_group):
		#print("É do mesmo grupo, ignorando")
		return

	if body.has_method("receber_dano"):
		#print("Chamando receber_dano com", dano)
		body.receber_dano(dano)
	else:
		#print("Não tem método receber_dano")
		pass
	hit_inimigo()


func _on_area_entered(area: Area2D):
	if area.is_in_group("hurtbox"):
		hit_inimigo()

func aplicar_upgrade(nivel, dano_base):
	var dano_base_skill := 0.0
	var multiplicador := 1.0
	match nivel:
		1:
			dano_base_skill = 5
			velocidade = 110.0		
			multiplicador = 1.0
		2:
			dano_base_skill = 10
			velocidade = 250.0
			multiplicador = 1.3
		3:
			dano_base_skill = 15
			velocidade = 500.0
			multiplicador = 1.7
			
	dano = (dano_base + dano_base_skill) * multiplicador
