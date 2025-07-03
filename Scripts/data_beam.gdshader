shader_type canvas_item;

uniform vec4 beam_color : source_color = vec4(0.0, 0.9, 1.0, 1.0); // azul-ciano
uniform float wave_strength = 10.0;
uniform float wave_frequency = 20.0;
uniform float wave_speed = 3.0;
uniform float softness = 0.1;

void fragment() {
    vec2 uv = UV;

    // Geração de ondulação lateral com seno
    float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * (wave_strength / 100.0);

    // Deformação horizontal (puxa a cor para o centro)
    float dist = abs(uv.x - 0.5 + wave);

    // Bordas suaves com fade
    float alpha = smoothstep(0.5, 0.5 - softness, dist);

    // Cor final
    COLOR = beam_color * alpha;
}
