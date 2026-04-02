shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_ring : source_color = vec4(1.0, 0.4, 0.1, 1.0);
uniform vec4 color_fill : source_color = vec4(1.0, 0.7, 0.2, 0.3);

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;  // centrar en -1..1
	float dist = length(uv);

	// Anillo expansivo
	float ring_radius = progress * 1.2;
	float ring_width = 0.12;
	float ring = smoothstep(ring_width, 0.0, abs(dist - ring_radius));

	// Fill interior que se desvanece
	float fill = smoothstep(ring_radius, ring_radius * 0.3, dist) * 0.4;

	// Segundo anillo más lento (eco)
	float ring2_radius = progress * 0.8;
	float ring2 = smoothstep(ring_width * 1.5, 0.0, abs(dist - ring2_radius)) * 0.5;

	float fade = 1.0 - smoothstep(0.6, 1.0, progress);

	vec4 col = color_ring * (ring + ring2) + color_fill * fill;
	col.a *= fade;

	COLOR = col;
}