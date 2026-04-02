shader_type canvas_item;

/* ===================================================== */
/* ====================== HALO BASE ==================== */
/* ===================================================== */
uniform bool enabled = true;

/* Color base del halo */
uniform vec4 halo_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);

/* Radio base del halo */
uniform float radius : hint_range(0.1, 1.5) = 0.85;

/* Separación respecto al centro */
uniform float offset : hint_range(-0.5, 0.5) = 0.0;

/* Grosor del anillo */
uniform float width : hint_range(0.001, 0.5) = 0.08;

/* Suavidad de los bordes */
uniform float softness : hint_range(0.001, 0.3) = 0.04;

/* ===================================================== */
/* =================== MOVIMIENTO ====================== */
/* ===================================================== */
uniform float speed = 1.2;
uniform float phase : hint_range(0.0, 1.0) = 0.0;

/* ===================================================== */
/* ===================== ARCO ========================== */
/* ===================================================== */
uniform float tail_length : hint_range(0.01, 1.0) = 0.25;
uniform float head_boost : hint_range(0.0, 6.0) = 2.5;
uniform float tail_falloff : hint_range(0.5, 6.0) = 1.8;

/* ===================================================== */
/* ===================== PULSO ========================= */
/* ===================================================== */
uniform float pulse_speed = 1.5;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.15;

/* ===================================================== */
/* =================== BRILLO (SHINE) ================== */
/* ===================================================== */
/* Brillo extra en la cabeza del arco */
uniform float shine_intensity : hint_range(0.0, 3.0) = 1.5;

/* Velocidad del shimmer/destello */
uniform float shimmer_speed = 2.0;

/* Intensidad del shimmer */
uniform float shimmer_amount : hint_range(0.0, 1.0) = 0.3;

/* ===================================================== */
/* ================== ANILLO INTERNO =================== */
/* ===================================================== */
/* Añade un segundo anillo más delgado y brillante */
uniform bool inner_ring_enabled = true;
uniform float inner_ring_offset : hint_range(0.0, 0.3) = 0.06;
uniform float inner_ring_width : hint_range(0.001, 0.1) = 0.02;
uniform float inner_ring_brightness : hint_range(0.0, 2.0) = 1.8;

/* ===================================================== */
/* =================== RESPLANDOR ====================== */
/* ===================================================== */
/* Glow suave alrededor del anillo */
uniform float glow_size : hint_range(0.0, 0.3) = 0.12;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	/* UV centrado */
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);
	
	/* Radio final */
	float r = radius + offset;
	
	/* ===================================================== */
	/* ANILLO PRINCIPAL */
	/* ===================================================== */
	float ring = smoothstep(r + width, r + width - softness, dist) -
	             smoothstep(r, r - softness, dist);
	
	/* ===================================================== */
	/* RESPLANDOR EXTERIOR */
	/* ===================================================== */
	float glow = 0.0;
	if (glow_size > 0.0) {
		float glow_dist = abs(dist - r) / glow_size;
		glow = exp(-glow_dist * glow_dist * 3.0) * glow_intensity;
	}
	
	/* ===================================================== */
	/* ANILLO INTERNO BRILLANTE */
	/* ===================================================== */
	float inner_ring = 0.0;
	if (inner_ring_enabled) {
		float inner_r = r - inner_ring_offset;
		inner_ring = smoothstep(inner_r + inner_ring_width, inner_r + inner_ring_width - softness * 0.5, dist) -
		             smoothstep(inner_r, inner_r - softness * 0.5, dist);
		inner_ring *= inner_ring_brightness;
	}
	
	/* ===================================================== */
	/* ARCO ANIMADO */
	/* ===================================================== */
	/* Ángulo polar */
	float angle = atan(uv.y, uv.x);
	float t = fract(angle / TAU + 0.5 + TIME * speed + phase);
	
	/* Cola con gradiente suave */
	float tail = clamp(1.0 - t / tail_length, 0.0, 1.0);
	tail = pow(tail, tail_falloff);
	
	/* Cabeza con pico brillante */
	float head = smoothstep(0.0, 0.03, t) * head_boost;
	
	/* Brillo extra en la cabeza */
	float shine = exp(-t * 15.0) * shine_intensity;
	head += shine;
	
	float arc = max(tail, head);
	
	/* ===================================================== */
	/* SHIMMER/DESTELLO */
	/* ===================================================== */
	float shimmer = 1.0;
	if (shimmer_amount > 0.0) {
		/* Patrón de shimmer que se mueve con el arco */
		float shimmer_pattern = sin((angle * 3.0) + TIME * shimmer_speed * TAU);
		shimmer_pattern = shimmer_pattern * 0.5 + 0.5;
		shimmer = 1.0 + shimmer_pattern * shimmer_amount;
	}
	
	/* ===================================================== */
	/* PULSO RESPIRATORIO */
	/* ===================================================== */
	float pulse = 1.0;
	if (pulse_amount > 0.0) {
		/* Pulso suave tipo "respiración" */
		pulse = 1.0 + sin(TIME * TAU * pulse_speed) * pulse_amount;
	}
	
	/* ===================================================== */
	/* COMPOSICIÓN FINAL */
	/* ===================================================== */
	/* Combinar anillo principal + anillo interno */
	float combined_ring = max(ring, inner_ring);
	
	/* Aplicar arco, shimmer y pulso */
	float final_intensity = (combined_ring * arc * shimmer + glow * arc) * pulse;
	
	/* Alpha final */
	float alpha = final_intensity * halo_color.a;
	alpha *= enabled ? 1.0 : 0.0;
	
	/* Color con boost de brillo en las zonas brillantes */
	vec3 final_color = halo_color.rgb * (1.0 + shine * 0.3);
	
	COLOR = vec4(final_color, alpha);
}