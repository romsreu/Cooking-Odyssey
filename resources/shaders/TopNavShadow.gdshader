shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform float shadow_height : hint_range(0.0, 0.5) = 0.15;
uniform float shadow_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Obtener el color original de la textura
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calcular la sombra solo en el borde inferior
    // UV.y va de 0 (arriba) a 1 (abajo)
    float shadow_start = 1.0 - shadow_height;
    float shadow_mask = smoothstep(shadow_start - shadow_softness, shadow_start + shadow_softness, UV.y);
    
    // Mezclar la textura original con la sombra
    vec3 final_color = mix(tex_color.rgb, shadow_color.rgb, shadow_mask * shadow_color.a);
    float final_alpha = tex_color.a;
    
    COLOR = vec4(final_color, final_alpha);
}