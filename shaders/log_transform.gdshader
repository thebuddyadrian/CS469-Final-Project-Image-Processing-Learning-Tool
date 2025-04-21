shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float scaling_constant : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = (log2(vec3(1, 1, 1) + COLOR.rgb * vec3(255, 255, 255)) / vec3(8, 8, 8)) * scaling_constant;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
