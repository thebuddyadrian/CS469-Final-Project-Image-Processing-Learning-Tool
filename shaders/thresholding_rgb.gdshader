shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float threshold : hint_range(0.0, 255.0) = 128.0;

void fragment() {
    vec4 orig_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    // Convert to grayscale using mean of rgb channels
    float gray = (orig_color.r + orig_color.g + orig_color.b) / 3.0;
    // Normalize threshold from 0–255 to 0–1
    float normalized_threshold = threshold / 255.0;
    // Apply threshold
    if (gray > normalized_threshold) {
        COLOR.rgb = vec3(1.0);
    } else {
        COLOR.rgb = vec3(0.0);
    }
    COLOR.a = orig_color.a;
}
