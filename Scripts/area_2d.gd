extends Area2D

@export var player_path : NodePath  

@export var player : Node2D


func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	if body.name == "Player":  # ou use `body is CharacterBody2D`
		print("Player entrou na área!")
