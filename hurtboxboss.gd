extends Area2D

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hitbox"):
		return

	if not ("source_group" in area and "damage" in area):
		return

	if get_parent().is_in_group(area.source_group):
		return

	if get_parent().has_method("take_damage"):
		get_parent().take_damage(area.damage)
