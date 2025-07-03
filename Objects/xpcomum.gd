extends Area2D

@export var experience = 1
var xpcomumload = preload("res://Textures/Items/Gems/XP COMUM.png")
var xpbossload = preload("res://Textures/Items/Gems/XP_BOSS.png")

var target = null
var speed = -2

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound= $CollectSound


func _ready() -> void:
	if experience < 5:
		return
	else:
		sprite.texture = xpbossload;



func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta
		
		
func collect():
	sound.play()
	collision.call_deferred("set","disabled")
	sprite.visible = false
	return experience
		

func _on_collect_sound_finished() -> void:
	queue_free()
