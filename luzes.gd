extends Light2D

@onready var sprite := $Sprite2D
@export var speed := 2.0
var time := 0.0

var colors = [
	Color(0.0, 1.0, 1.0),    # Ciano neon
	Color(0.7, 0.0, 1.0),    # Roxo elétrico
	Color(1.0, 0.0, 0.8),    # Magenta neon
	Color(0.0, 1.0, 0.3),    # Verde ácido
	Color(0.0, 0.4, 0.8),    # Azul neon escuro
	Color(0.05, 0.05, 0.1)   # Azul quase preto para contraste
]

func _process(delta):
	time += delta * speed

	var t = (sin(time) + 1.0) / 2.0

	var index = int(time) % colors.size()
	var next_index = (index + 1) % colors.size()

	color = colors[index].lerp(colors[next_index], t)
	sprite.modulate = color
	energy = lerp(0.3, 1.0, t)
