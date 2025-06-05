extends Node2D

@export var speed_range := Vector2(0.3, 0.7) # mais lento = mais suave
var speed := 1.0

@onready var luz: PointLight2D = $PointLight2D4
@onready var sprite: Sprite2D = $PointLight2D4/Sprite2D

# Cores cyber/tecnológicas
var colors = [
	Color(0.0, 1.0, 1.0),   # Ciano
	Color(1.0, 0.0, 1.0),   # Magenta
	Color(0.0, 1.0, 0.0),   # Verde neon
	Color(1.0, 1.0, 0.0),   # Amarelo
	Color(0.0, 0.5, 1.0),   # Azul elétrico
	Color(1.0, 0.4, 0.7),   # Rosa neon
	Color(0.3, 1.0, 0.7),   # Verde água neon
]

var from_color: Color
var to_color: Color
var lerp_time := 0.0
var transition_duration := 3.0

func _ready():
	randomize()
	# Escolhe duas cores iniciais aleatórias
	from_color = colors[randi() % colors.size()]
	to_color = colors[randi() % colors.size()]
	speed = randf_range(speed_range.x, speed_range.y)
	transition_duration = 1.0 / speed # quanto menor a velocidade, mais tempo pra trocar

func _process(delta):
	lerp_time += delta

	var t = clamp(lerp_time / transition_duration, 0.0, 1.0)
	var current_color = from_color.lerp(to_color, t)

	# Aplica nas luzes
	luz.color = current_color
	luz.energy = lerp(0.3, 1.0, sin(t * PI)) # curva suave
	sprite.modulate = current_color

	# Quando terminar a transição, começa outra
	if t >= 1.0:
		from_color = to_color
		var next = randi() % colors.size()
		while colors[next] == from_color:
			next = randi() % colors.size()
		to_color = colors[next]
		speed = randf_range(speed_range.x, speed_range.y)
		transition_duration = 1.0 / speed
		lerp_time = 0.0
