extends ColorRect

var mouse_over = false
var skill = null

@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	self.custom_minimum_size = Vector2(200, 150)
	self.visible = true
	self.modulate = Color(1, 1, 1, 1)
	print("Instanciado:", self.name)

func set_data(skill_data):
	skill = skill_data
	$label_name.text = skill.name
	$label_description.text = skill.description
	$ColorRect/TextureRect.texture = load(skill.icon_path)
	$label_level.text = str("Nível ", skill.level)  # Se quiser mostrar o nível

func _input(event: InputEvent) -> void:
	if event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", skill) # ✔️ usa a variável correta
			queue_free() # opcional, pra sumir quando clica

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
