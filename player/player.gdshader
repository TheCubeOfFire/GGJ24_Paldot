shader_type canvas_item;

uniform float cream_quantity = 0.0;

void fragment() {
	vec4 pixel_color_alpha = texture(TEXTURE, UV);
	vec3 pixel_color = pixel_color_alpha.rgb;
	float pixel_alpha = pixel_color_alpha.a;

	COLOR = vec4(mix(pixel_color, vec3(1), cream_quantity), pixel_alpha);
}
