shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float input_lower_bound : hint_range(0.0, 255.0) = 0;
uniform float input_upper_bound : hint_range(0.0, 255.0) = 255;
uniform float output_lower_bound : hint_range(0.0, 255.0) = 0.0;
uniform float output_upper_bound : hint_range(0.0, 255.0) = 255;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = (((output_upper_bound - output_lower_bound) / (input_upper_bound - input_lower_bound)) * ((COLOR.rgb * 255.0) - vec3(input_lower_bound)) + vec3(output_lower_bound)) / 255.0;
	COLOR.rgb = clamp(COLOR.rgb, 0.0, 1.0);
}
