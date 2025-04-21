shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float brightness_mult : hint_range(0.0, 5.0) = 1.00;
uniform float skew_red : hint_range(0.0, 5.0) = 1.00;
uniform float skew_blue : hint_range(0.0, 5.0) = 1.00;
uniform float skew_green : hint_range(0.0, 5.0) = 1.00;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.r = COLOR.r * brightness_mult * skew_red;
	COLOR.g = COLOR.g * brightness_mult * skew_green;
	COLOR.b = COLOR.b * brightness_mult * skew_blue;
}
