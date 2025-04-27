shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform int radius: hint_range(1, 3);
uniform float horizontal_skew: hint_range(0.0, 2.0);
uniform float vertical_skew: hint_range(0.0, 2.0);

const int MAX_KERNEL_SIZE = 25;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 offsets[25];
	float skews[25];
	for(int i = -radius ; i <= radius; i++){
		for(int j = -radius; j <= radius; j++){
			// Calculate the offset from the current pixel
			offsets[i * radius + j] = vec2(float(i), float(j)) * SCREEN_PIXEL_SIZE;
			skews[i * radius + j] = 1.0 + (horizontal_skew * (float(i) / float(radius))) + (vertical_skew * (float(j) / float(radius)));
		}
	}
	vec3 result = vec3(0.0);
	for(int i = 0; i < radius * radius; i++) {
		vec3 sample = texture(SCREEN_TEXTURE, SCREEN_UV + offsets[i]).rgb;
		result += sample * skews[i];
	}
	
	COLOR.rgb = result / float(radius * radius);
	COLOR.a = 1.0;
}
