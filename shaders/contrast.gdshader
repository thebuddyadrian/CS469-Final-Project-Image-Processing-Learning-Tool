shader_type canvas_item;

uniform float multiplier: hint_range(0, 2.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * multiplier;
	COLOR.a = 1.0;
}