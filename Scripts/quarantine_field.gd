extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

@export var nivel := 1
@export var hp := 1
@export var velocidade := 100.0
@export var dano := 5
@export var knock_amount := 100
@export var tamanho_ataque := 1.0
@export var source_group := ""

@export var intervalo_dano := 1.0  # segundos entre cada dano
@export var slow_percent := 0.5    # 50% de lentidão
@export var duracao := 7.0 
@export var cooldown = 4.0
var tempo_para_sumir := 3.0
var tempo_desvanecimento := 2.0
var tempo_passado := 0.0
var comecar_desvanecer := false

var inimigos_na_area := {}

func _ready():
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	add_to_group("hitbox")
	$AnimatedSprite2D.play("Explosion")
	rotation = 0
	dano = 15
	scale = Vector2.ONE * tamanho_ataque
	
	# Timer de dano periódico
	var timer = Timer.new()
	timer.wait_time = intervalo_dano
	timer.autostart = true
	timer.one_shot = false
	timer.name = "DanoTimer"
	add_child(timer)
	timer.connect("timeout", Callable(self, "_aplicar_dano_periodico"))

	# Timer de vida útil do tornado
	var duracao_timer = Timer.new()
	duracao_timer.wait_time = duracao
	duracao_timer.one_shot = true
	duracao_timer.autostart = true
	add_child(duracao_timer)
	duracao_timer.connect("timeout", Callable(self, "_on_destruir"))
	

func _physics_process(delta):
	rotation += delta * 2.0
	
	if !comecar_desvanecer:
		tempo_passado += delta
		if tempo_passado >= tempo_para_sumir:
			comecar_desvanecer = true
			tempo_passado = 0.0  # reinicia para o fade-out

	elif comecar_desvanecer:
		tempo_passado += delta
		var alpha = 1.0 - (tempo_passado / tempo_desvanecimento)
		alpha = clamp(alpha, 0.0, 1.0)
		$AnimatedSprite2D.modulate.a = alpha
		
		if alpha <= 0.0:
			queue_free()  # remove da cena após sumir

func _on_area_entered(area: Area2D):
	if area.is_in_group("inimigo") and area.get_parent() not in inimigos_na_area:
		var alvo = area.get_parent()
		inimigos_na_area[alvo] = true

		# aplica lentidão se o inimigo tiver método
		if alvo.has_method("aplicar_slow"):
			alvo.aplicar_slow(slow_percent)

func _on_area_exited(area: Area2D):
	var alvo = area.get_parent()
	if alvo in inimigos_na_area:
		inimigos_na_area.erase(alvo)

		# remove slow se tiver método
		if alvo.has_method("remover_slow"):
			alvo.remover_slow()

func _aplicar_dano_periodico():
	for inimigo in inimigos_na_area.keys():
		if is_instance_valid(inimigo) and inimigo.has_method("receber_dano"):
			print("chamando receber dano com 15")
			inimigo.receber_dano(dano)

func _on_destruir():
	queue_free()
	
	
func aplicar_upgrade(nivel):
	var tamanho = 1.0
	match nivel:
		1:
			dano = 15
			slow_percent = 0.2
			tamanho = 1.0
			cooldown = 4.0
		2:
			dano = 25
			slow_percent = 0.4
			tamanho = 1.3
			cooldown = 3.5
		3:
			dano = 40
			slow_percent = 0.6
			tamanho = 1.6
			cooldown = 2.8

	# Aplica no visual
	scale = Vector2.ONE * tamanho
	$AnimatedSprite2D.scale = Vector2.ONE * tamanho

	
