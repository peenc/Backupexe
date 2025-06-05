extends Area2D

@export var damage: int = 10
@export var source_group: String = ""  # "player" ou "inimigo"

func _ready():
	add_to_group("hitbox")
