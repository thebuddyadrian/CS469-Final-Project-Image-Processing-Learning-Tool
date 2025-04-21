shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float gamma : hint_range(0.01, 5.0) = 1.0;
uniform float scaling_constant : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = scaling_constant * pow(COLOR.rgb, vec3(gamma));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
