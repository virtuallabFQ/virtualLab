shader_type spatial;
render_mode cull_disabled, shadows_disabled, blend_mix;

group_uniforms PhysicsSetByScript;
uniform vec2 coeff;
uniform float vel; 

group_uniforms Visuals;
uniform vec4 liquid_color : source_color = vec4(0.7, 0.1, 0.6, 1.0);
uniform vec4 foam_color   : source_color = vec4(0.9, 0.3, 0.8, 1.0);
uniform float foam_line   : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float fill_amount : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform vec2 size         = vec2(1.0, 1.0);
uniform float glass_thickness = 0.05;
uniform float scale       = 1.0;
uniform float wave_intensity  = 0.05;
uniform sampler2D waves_noise;

group_uniforms Bubbles;
uniform bool AlwaysBubbles  = false;
uniform float BubbleStrength: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float BubbleMask    : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform vec2 BubbleSpeed    = vec2(3.0, 3.0);
uniform sampler2D bubbles_tex;

varying vec3 pos;
varying float rot_scale;
varying vec3 weights;
varying vec2 uv_time;

void vertex() {
	VERTEX -= glass_thickness * NORMAL;
	
	mat3 model_mat = mat3(MODEL_MATRIX);
	pos = model_mat * VERTEX;
	
	uv_time = (TIME * 0.5) * vec2(1.0, 1.0); 
	
	vec3 world_up = model_mat[1]; 
	rot_scale = mix(size.x, size.y, abs(world_up.y));
	
	weights = model_mat * NORMAL;
	weights *= weights;
}

void fragment() {
	vec2 base_uv = (2.0 * pos.xz) * scale;
	vec2 wave_tex = texture(waves_noise, base_uv + uv_time).rg;
	
	float wave = wave_intensity * length(coeff) * (wave_tex.r + wave_tex.g - 1.0) + dot(pos.xz, coeff);
	wave *= smoothstep(0.05, 0.25, fill_amount);
	
	float liquid_line = (fill_amount * 2.0 - 1.0 + wave) * rot_scale;
	
	if (pos.y > liquid_line) discard;
	
	float b_weight = mix(vel, BubbleStrength, float(AlwaysBubbles));
	vec2 b_dist = wave_tex * 0.01;
	
	float b_x = smoothstep(BubbleMask, 1.0, texture(bubbles_tex, scale * BubbleSpeed * pos.yx + b_dist - TIME * vec2(2.0, 0.5)).r);
	float b_y = smoothstep(BubbleMask, 1.0, texture(bubbles_tex, scale * BubbleSpeed * pos.yz + b_dist - TIME * vec2(2.0, 0.0)).r);
	
	float total_bubbles = (b_x + b_y) * weights.z * weights.x * b_weight;

	float front = float(FRONT_FACING);
	float back  = 1.0 - front;
	
	float foam = smoothstep(liquid_line - foam_line * scale * rot_scale, liquid_line, pos.y);
	
	vec3 foam_norm = vec3(coeff.x, 1.0, coeff.y);
	
	vec3 c_front = mix(liquid_color.rgb, mix(liquid_color.rgb, foam_color.rgb, foam), vel);
	vec3 c_back  = mix(liquid_color.rgb, foam_color.rgb, vel);
	
	float a_front = mix(liquid_color.a, mix(liquid_color.a, foam_color.a, foam), vel);
	float a_back  = mix(liquid_color.a, foam_color.a, vel);

	ALBEDO = (c_front * front) + (c_back * back);
	NORMAL = (mix(NORMAL, mix(NORMAL, foam_norm, foam), vel) * front) + (foam_norm * back);
	ALPHA  = (a_front * front) + (a_back * back);
	
	BACKLIGHT.z = total_bubbles;
}

void light() {
	float d = max(dot(-VIEW, LIGHT), 0.0);
	float dd = d * d;
	DIFFUSE_LIGHT = (dd - BACKLIGHT.z * d) * liquid_color.rgb;
}