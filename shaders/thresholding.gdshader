shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float red_threshold : hint_range(0.0, 100.0) = 50.0;
uniform float green_threshold : hint_range(0.0, 100.0) = 50.0;
uniform float blue_threshold : hint_range(0.0, 100.0) = 50.0;

void fragment() {
	// Called for every pixel the material is visible on.
	float red_threshold_normalized = red_threshold / 100.0;
	float green_threshold_normalized = green_threshold / 100.0;
	float blue_threshold_normalized = blue_threshold / 100.0;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	if(COLOR.r > red_threshold_normalized && COLOR.g > green_threshold_normalized && COLOR.b > blue_threshold_normalized) {
		COLOR.rgb = vec3(1.0, 1.0, 1.0);
	}
	else { COLOR.rgb = vec3(0.0,0.0,0.0); }
}
