extends Area2D

@export var nivel := 1
@export var duracao := 3.0
@export var tempo_desvanecimento := 1.0
@export var cooldown = 10

var tempo_passado := 0.0
var desvanecendo := false
var player = null

signal escudo_finalizado


func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_meta("imune", true)

	$AnimatedSprite2D.play("escudo")
	
	# Timer de duração
	var timer = Timer.new()
	timer.wait_time = duracao
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_iniciar_desvanecimento"))

func _physics_process(delta):
	if desvanecendo:
		tempo_passado += delta
		var alpha = 1.0 - (tempo_passado / tempo_desvanecimento)
		alpha = clamp(alpha, 0.0, 1.0)
		$AnimatedSprite2D.modulate.a = alpha
		
		if alpha <= 0.0:
			_finalizar()

func _iniciar_desvanecimento():
	desvanecendo = true
	tempo_passado = 0.0

func _finalizar():
	if player:
		player.set_meta("imune", false)
	emit_signal("escudo_finalizado")
	queue_free()


func aplicar_upgrade(nivel):
	var tempo = 3.0
	var fade = 1.0
	var tamanho = 1.3
	match nivel:
		1:
			tempo = 3.0
			fade = 1.5
			tamanho = 1.3
			cooldown = 6.0
		2:
			tempo = 4.5
			fade = 1.7
			tamanho = 1.4
			cooldown = 5.0
		3:
			tempo = 6.0
			fade = 1.5
			tamanho = 1.5
			cooldown = 4.0
	
	duracao = tempo
	tempo_desvanecimento = fade
	scale = Vector2.ONE * tamanho
	$AnimatedSprite2D.scale = Vector2.ONE * tamanho
