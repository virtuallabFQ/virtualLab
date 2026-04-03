shader_type spatial;
render_mode cull_disabled;

uniform vec4 liquid_color : source_color = vec4(0.0, 0.4, 0.8, 0.5);
// Agora o fill_level é uma coordenada Y real no teu mundo (ex: 1.5 metros de altura)
instance uniform float fill_level_world : hint_range(0, 15.0) = 0.0;

varying float world_y;

void vertex() {
    // Calculamos a posição real do vértice no mundo
    world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
    // O corte é feito com base na altura do MUNDO
    if (world_y > fill_level_world) {
        discard;
    }
    
    ALBEDO = liquid_color.rgb;
    ALPHA = liquid_color.a;
}