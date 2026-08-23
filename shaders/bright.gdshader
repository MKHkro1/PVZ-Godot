shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness : hint_range(1.0, 5.0) = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (color.a > 0.0001) {
        color.rgb /= color.a;
    }
	color.rgb *= brightness;
	COLOR = color;

	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
