shader_type spatial;
render_mode cull_disabled, blend_add, unshaded;

uniform float time_speed = 1.0;
uniform float surface_speed = 1.0;
uniform float spin = 0.0; 
uniform float brightness = 0.06;
uniform float color_intensity = 0.0;
uniform float horizontal_frequency = 2.0;
uniform float vertical_frequency = 2.0;
uniform float size = -1.75;
uniform float banding_bias = 1.85;

uniform sampler2D wave_texture;
uniform sampler2D noise_texture;
uniform float wave_height = 0.005;
uniform float texture_height = 0.05;

uniform vec4 color1 : source_color = vec4(0.59, 0.761, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.274, 0.474, 0.98, 1.0);
uniform vec4 color3 : source_color = vec4(0.059, 0.389, 0.85, 1.0);
uniform vec4 color4 : source_color = vec4(0.0, 0.267, 1.0, 1.0);

varying vec2 v_noise_uv;
varying vec2 v_wave_uv;

void vertex() {
	float time = -TIME * time_speed;
	
	v_wave_uv = UV + (time * surface_speed);
	v_noise_uv = vec2(UV.x * horizontal_frequency + spin * (time * 0.5), (UV.y * vertical_frequency) + time);
	
	float w_tex = texture(wave_texture, v_wave_uv).r;
	float n_tex = texture(noise_texture, v_noise_uv).r;
	
	VERTEX += NORMAL * ((wave_height * w_tex) + (texture_height * n_tex));
}

void fragment() {
	float noise_value = texture(noise_texture, v_noise_uv).r;
	
	float normal_facing = dot(NORMAL, VIEW);
	normal_facing += (noise_value - 0.5 + size) * 0.3;

	float band = normal_facing * (3.0 * banding_bias);

	if (band <= 1.5) {
		discard;
	}
	
	vec3 band_color;
	
	if(band <= 2.0){
		band_color = mix(color1.rgb, color2.rgb, -0.01 / (band - 2.01));
	}
	else if (band <= 2.5) {
		band_color = mix(color2.rgb, color3.rgb, -0.01 / (band - 2.51));
	}
	else if (band <= 2.9) {
		band_color = mix(color3.rgb, color4.rgb, -0.01 / (band - 2.91));
	}
	else {
		band_color = color4.rgb;
	}
	
	vec3 final_color = brightness * (1.0 + (band_color * color_intensity)) * band_color;
	
	ALBEDO = min(max(final_color, vec3(0.0)), vec3(brightness));
}