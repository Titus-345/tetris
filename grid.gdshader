shader_type canvas_item;

uniform float tile_size = 16.0;
uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.15);
uniform vec2 offset = vec2(0.0, 0.0);

void fragment() {
	vec2 pixel = FRAGCOORD.xy - offset;
	vec2 mod_pos = mod(pixel, tile_size);
	
	if (mod_pos.x < 1.0 || mod_pos.y < 1.0) {
		COLOR = grid_color;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}