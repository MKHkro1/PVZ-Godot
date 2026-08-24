shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.01) {
		discard;
	}
	COLOR = tex * COLOR;
}
