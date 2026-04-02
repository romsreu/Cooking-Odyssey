shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);

	// Rayos radiales tipo starburst
	float spokes = 8.0;
	float ray = abs(sin(angle * spokes * 0.5));
	ray = pow(ray, 6.0);  // hacerlos finos

	// Expansión
	float radius = progress * 1.4;
	float ring = smoothstep(0.15, 0.0, abs(dist - radius));

	// Colores arcoíris según ángulo
	float hue = fract(angle / (2.0 * 3.14159) + progress * 0.5);
	// HSV to RGB simplificado
	vec3 rainbow = clamp(abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);

	float fade = 1.0 - smoothstep(0.65, 1.0, progress);
	float inner_fade = smoothstep(0.0, 0.3, progress);

	float alpha = (ring * 0.8 + ray * smoothstep(radius, 0.0, dist) * 0.6) * fade * inner_fade;

	COLOR = vec4(rainbow + 0.3, alpha);
}