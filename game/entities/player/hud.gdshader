shader_type canvas_item;

uniform vec4 eigengrau_color : source_color = vec4(0.07, 0.07, 0.09, 1.0);
uniform float static_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float animation_speed = 12.0;
uniform vec2 virtual_resolution = vec2(320.0, 180.0);
uniform float fade : hint_range(0.0, 1.0) = 0.0;

// high-frequency pseudo-random function
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // pixelate the UV coordinates
    vec2 pixelated_uv = floor(UV * virtual_resolution) / virtual_resolution;
    
    // quantize TIME
    float time_step = floor(TIME * animation_speed);
    
    // generate the pseudo-random value
    float noise = random(pixelated_uv + time_step);
    
    // center the noise around 0 (-0.5 to 0.5) shifting from lighter to darker
    float noise_shift = (noise - 0.5) * static_intensity;
    
    // mix it directly into base color
    vec4 final_color = eigengrau_color;
    final_color.rgb += vec3(noise_shift);
    
	// apply fade to final color for opening and closing
    COLOR = final_color * fade;
}
