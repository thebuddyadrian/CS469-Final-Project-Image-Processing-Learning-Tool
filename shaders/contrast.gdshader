shader_type canvas_item;

uniform float multiplier: hint_range(0, 2.0) = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV) * multiplier;
}