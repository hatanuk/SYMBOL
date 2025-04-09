// Hey this is Hei! This shader "fakes" a 3D-camera perspective on CanvasItems.
// License: MIT

shader_type canvas_item;

// Camera FOV
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;
// At 0, the image retains its size when unrotated.
// At 1, the image is resized so that it can do a full
// rotation without clipping inside its rect.
uniform float inset : hint_range(0, 1) = 0.0;
// Consider changing this to a uniform and changing it from code

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;
uniform vec2 burn_offset;

varying flat vec2 o;
varying vec3 p;


uniform sampler2D vertical_gradient; // used to set alpha values. So you can use this to make the effect dis-/re-appear at points
uniform sampler2D color_gradient; // sets the effect color, supports 2d gradients
uniform float size_effect: hint_range(-5.0, 5.0, 0.05) = 0.1; // size of the effect
uniform float speed = 1; // effect speed; Will reverse effect if set to negative
uniform float highlight_strength: hint_range(-4.0, 4.0, 0.05) = 0.5; // how strong the color overides the base color
uniform bool color_mode_toggle = false; // changes how the color gradient is applied. Default is on the entire texture, if set to true it is only applied to the effect
uniform bool is_horizontal = false; // changes direction from vertical to horizontal
uniform float pause_duration = 0.5; // duration of the pause between highlight cycles
uniform vec4 modulate: source_color;


// Creates rotation matrix
void vertex(){
	float sin_b = sin(y_rot / 180.0 * PI);
	float cos_b = cos(y_rot / 180.0 * PI);
	float sin_c = sin(x_rot / 180.0 * PI);
	float cos_c = cos(x_rot / 180.0 * PI);

	mat3 inv_rot_mat;
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;

	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;

	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;


	float t = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3((UV - 0.5), 0.5 / t);
	float v = (0.5 / t) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;

	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * t * (1.0 - inset);
}

void fragment(){
	if (cull_back && p.z <= 0.0) discard;
	vec2 uv = (p.xy / p.z).xy - o;
    COLOR = texture(TEXTURE, uv + 0.5);
	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);

	//vec2 scrolled_uv = UV + TIME * dissolve_scroll_speed;
	vec4 main_texture = texture(TEXTURE, uv + 0.5);
	float angle = length(burn_offset) * 1.0;
	float cos_a = cos(angle);
	float sin_a = sin(angle);

	vec2 centered_uv = UV - vec2(0.5);
	vec2 rotated_uv = vec2(
	    centered_uv.x * cos_a - centered_uv.y * sin_a,
	    centered_uv.x * sin_a + centered_uv.y * cos_a
	) + vec2(0.5);

	vec2 wrapped_uv = fract(rotated_uv + burn_offset);
	vec4 noise_texture = texture(dissolve_texture, wrapped_uv);
	float burn_size_step = burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
	float threshold = smoothstep(noise_texture.x-burn_size_step, noise_texture.x, dissolve_value);
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);

	COLOR.a *= threshold;
	COLOR.rgb = mix(burn_color.rgb, main_texture.rgb, border);

	// set up base parameters
	vec4 old_color = COLOR;
	float time = TIME * abs(speed); // Absolute time to handle both positive and negative speeds
	float effect_cycle_duration = 1.0 + pause_duration; // total time for one cycle and pause
	float mod_time = mod(time, effect_cycle_duration); // current time within the cycle

	// Handle the pause
	float progress = mod_time / (1.0); // Normalize mod_time to the active highlight duration only (excluding pause)

	// Ensure the effect is clamped during the pause period
	if (mod_time > 1.0) {
		progress = 1.0; // Hold the highlight at the final position during the pause
	}

	// Reverse the direction if speed is negative
	if (speed < 0.0) {
		progress = 1.0 - progress; // Reverse progress when speed is negative
	}

	// Set the current time and bounds for the highlight effect
	float current_time = mix(0.0 - size_effect, 1.0 + size_effect, progress);
	float effect_lower_bound = current_time - size_effect;
	float effect_upper_bound = current_time + size_effect;
	float position_value = (is_horizontal) ? UV.x : UV.y;

	// Smooth out the lower/upper bounds with the UV values to calculate how far from the middle point (the effect) the pixel is
	float effect_distance = smoothstep(effect_lower_bound, current_time, position_value) - smoothstep(current_time, effect_upper_bound, position_value);

	// Get the position of the pixel within the effect for the inner_gradient color mode
	float inner_effect_position = smoothstep(effect_lower_bound, effect_upper_bound, position_value);
	vec2 color_position = (color_mode_toggle) ? vec2(UV.x, inner_effect_position) : vec2(progress);

	// Get the new color from the gradient
	vec4 new_color = vec4(texture(color_gradient, color_position));

	// Calculate the vertical gradient and alpha_values
	new_color = mix(old_color, new_color, vec4(texture(vertical_gradient, vec2(progress))));

	// Apply the color to the texture
	COLOR.rgb = mix(old_color.rgb, new_color.rgb, vec3(effect_distance * highlight_strength));

	COLOR *= modulate;
}