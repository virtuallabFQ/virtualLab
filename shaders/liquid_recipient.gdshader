shader_type spatial;
render_mode cull_disabled, depth_draw_always;

instance uniform vec4 liquid_color : source_color = vec4(0.780, 0.874, 1.0, 0.392);

instance uniform float fill_percentage : hint_range(0.0, 1.0) = 0.5;
instance uniform float min_y_local = -0.5;
instance uniform float max_y_local = 0.5;

varying vec3 local_pos;
varying vec3 world_up_local;

void vertex() {
    local_pos = VERTEX;
    world_up_local = normalize((inverse(MODEL_MATRIX) * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
}

void fragment() {
    if (fill_percentage <= 0.001) { discard; }

    float current_height = mix(min_y_local, max_y_local, fill_percentage);
    float fragment_height = dot(local_pos, world_up_local);

    if (fragment_height > current_height) { discard; }

    ALBEDO = liquid_color.rgb;
    ALPHA = liquid_color.a;
    ROUGHNESS = 0.1;
    SPECULAR = 0.5;

    if (!FRONT_FACING) {
        ALBEDO = mix(liquid_color.rgb, vec3(1.0), 0.3);
    }
}