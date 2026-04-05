shader_type spatial;
render_mode cull_back, depth_draw_always, blend_mix;

uniform vec4 drop_color : source_color = vec4(0.6, 0.8, 1.0, 0.6);
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.02;
uniform float fresnel_power : hint_range(1.0, 8.0) = 4.0;

void fragment() {
    vec3 normal = NORMAL;
    float fresnel = pow(1.0 - clamp(dot(normal, VIEW), 0.0, 1.0), fresnel_power);
    
    ALBEDO = drop_color.rgb;
    ALPHA = clamp(drop_color.a + fresnel * 0.4, 0.0, 1.0);
    ROUGHNESS = 0.0;
    METALLIC = 0.1;
    SPECULAR = 1.0;
    RIM = 0.8;
    RIM_TINT = 0.5;
}