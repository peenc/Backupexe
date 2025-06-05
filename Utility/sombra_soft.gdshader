shader_type canvas_item;

uniform vec4 shadow_color : hint_color = vec4(0, 0, 0, 0.5);
uniform float blur_size = 8.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = vec4(0.0);

    float total = 0.0;

    for (float x = -blur_size; x <= blur_size; x++) {
        for (float y = -blur_size; y <= blur_size; y++) {
            float weight = exp(-((x * x + y * y) / (blur_size * blur_size)));
            col += shadow_color * weight;
            total += weight;
        }
    }

    col /= total;
    COLOR = col;
}
