extends Polygon2D

@export var sprite_path: NodePath = NodePath("../AnimatedSprite2D")
var sprite: AnimatedSprite2D

func _ready():
	sprite = get_node(sprite_path)
	update_polygon()

func _process(_delta):
	update_polygon()

func update_polygon():
	var tex: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	
	if tex:
		var poly = get_polygon_from_texture(tex)
		if poly.size() > 0:
			# Centraliza e aplica a escala do sprite
			var scaled_poly = PackedVector2Array()
			for v in poly:
				var centered = v - tex.get_size() * 0.5
				scaled_poly.append(centered * sprite.scale)
			polygon = scaled_poly
		else:
			# fallback: retângulo do tamanho do sprite
			var size = tex.get_size() * sprite.scale * 0.5
			polygon = PackedVector2Array([
				Vector2(-size.x, -size.y),
				Vector2(size.x, -size.y),
				Vector2(size.x, size.y),
				Vector2(-size.x, size.y)
			])
	else:
		polygon = PackedVector2Array()

func get_polygon_from_texture(texture: Texture2D, threshold := 0.1) -> PackedVector2Array:
	var img: Image = texture.get_image()
	img.decompress()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(img, threshold)

	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, img.get_size()))

	if polys.size() > 0:
		return polys[0]  # Retorna o primeiro polígono encontrado
	else:
		return PackedVector2Array()
