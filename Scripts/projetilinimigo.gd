extends Area2D

@export var SPEED := 120
@export var dano := 5
var direcao := Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Opcional para autodestruição depois de 3 segundos
	await get_tree().create_timer(3).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	position += direcao * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(dano)
		queue_free()
