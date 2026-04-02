shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool is_horizontal = true;
uniform vec4 color_core : source_color = vec4(1.0, 0.95, 0.4, 1.0);
uniform vec4 color_glow : source_color = vec4(1.0, 0.5, 0.1, 1.0);

void fragment() {
	vec2 uv = UV;

	// Eje del rayo según dirección
	float axis = is_horizontal ? uv.y : uv.x;
	float perp = is_horizontal ? uv.x : uv.y;

	// Core del rayo: franja fina en el centro
	float center_dist = abs(axis - 0.5);
	float core = smoothstep(0.08, 0.0, center_dist);

	// Glow más suave alrededor
	float glow = smoothstep(0.35, 0.0, center_dist);

	// Expansión desde el centro hacia los bordes
	float expand_mask = smoothstep(0.0, 0.5, progress) - smoothstep(0.5, 1.0, progress);

	// Borde de la onda que viaja
	float wave_edge = abs(perp - progress);
	float wave = smoothstep(0.06, 0.0, wave_edge) * 2.0;

	// Fade out global al final
	float fade = 1.0 - smoothstep(0.7, 1.0, progress);

	vec4 col = mix(color_glow * glow, color_core * core, core) + color_core * wave;
	col.a *= fade * (core + glow * 0.4 + wave * 0.3);

	COLOR = col;
}