shader_type spatial;

global uniform vec3 ocean_pos;

uniform vec3 albedo : source_color = vec3(0.0, 0.32, 0.43);
uniform vec3 albedo2 : source_color = vec3(0.0, 0.47, 0.76);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D wave; 
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2; 

uniform vec2 wave_direction = vec2(0.5, -0.2);
uniform vec2 wave_direction2 = vec2(-0.5, 0.5); 
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.1;
uniform float noise_scale = 20.0;
uniform float height_scale = 2.0;

varying vec3 world_pos;
varying vec2 uv_time1;
varying vec2 uv_time2;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normal, view), 0.0, 1.0 )), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	uv_time1 = (TIME * wave_direction) * time_scale;
	uv_time2 = (TIME * wave_direction2) * time_scale;
	
	float vertex_distance = clamp(distance(world_pos, ocean_pos), 0.0, 85.0);
	float distance_fade = 1.0 - (vertex_distance * 0.01176);
	
	float h = texture(wave, (world_pos.xz * (1.0 / noise_scale)) + uv_time1).r;
	
	VERTEX.y += h * height_scale * distance_fade;
}

void fragment() {
	vec3 normal1 = texture(texture_normal, (world_pos.xz * 0.1) + uv_time1).rgb;
	vec3 normal2 = texture(texture_normal2, (world_pos.xz * 0.1) + uv_time2).rgb;
	vec3 normal_blend = mix(normal1, normal2, 0.5);
	
	float f = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, f);
	
	ALBEDO = surface_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}