extends PointLight2D

@export var speed_range := Vector2(2.0, 5.0)  # velocidade de oscilação mínima e máxima
var time := 0.0
var speed := 1.0

# Lista de cores neon/cyber para oscilação
var colors = [
	Color(0.0, 1.0, 1.0),   # Ciano
	Color(1.0, 0.0, 1.0),   # Magenta
	Color(0.0, 1.0, 0.0),   # Verde
	Color(1.0, 1.0, 0.0),   # Amarelo
	Color(0.0, 0.5, 1.0),   # Azul elétrico
	Color(1.0, 0.4, 0.7),   # Rosa neon
	Color(0.3, 1.0, 0.7),   # Verde água neon
]

var index := 0
var next_index := 1

@onready var sprite: Sprite2D = $PointLight2D3/Sprite2D

func _ready():
	randomize()
	index = randi() % colors.size()
	next_index = (index + 1 + randi() % (colors.size() - 1)) % colors.size()
	speed = randf_range(speed_range.x, speed_range.y)

func _process(delta):
	time += delta * speed
	var t = abs(sin(time))
	var current_color = colors[index].lerp(colors[next_index], t)

	color = current_color
	energy = lerp(0.3, 1.0, t)

	if sprite:
		sprite.modulate = current_color

	if t > 0.99:
		index = next_index
		next_index = (index + 1 + randi() % (colors.size() - 1)) % colors.size()
