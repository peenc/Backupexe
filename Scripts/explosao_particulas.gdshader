shader_type particles;

uniform vec4 color_start : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 color_end : source_color = vec4(1.0, 0.0, 1.0, 0.0);
uniform float flicker_speed = 30.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;
    float pulse = abs(sin(TIME * flicker_speed));
    
    COLOR = mix(color_start, color_end, alpha) * pulse;
}
