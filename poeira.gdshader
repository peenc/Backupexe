shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 0.2;
uniform vec2 speed = vec2(10.0, 0.0);
uniform sampler2D dust_texture : hint_default_white;

void fragment() {
    vec2 uv = UV;
    uv += TIME * speed * 0.01; // Movimento sutil da poeira

    vec4 tex = texture(dust_texture, fract(uv));
    tex.a *= opacity;

    COLOR = tex;
}
