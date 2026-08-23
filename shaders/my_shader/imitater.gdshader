shader_type canvas_item;

varying vec4 v_modulate;

uniform float gray_strength : hint_range(0.0, 1.0) = 1.0;   // 灰度强度
uniform float whiteness : hint_range(0.0, 1.0) = 0.0;       // 白化强度
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;     // 亮度调节（加法）
uniform float contrast : hint_range(0.0, 3.0) = 1.0;        // 对比度调节

void vertex() {
    v_modulate = COLOR;  // 保存 node 本身的 modulate (包括 self_modulate)
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // 1. 转灰度 (加权灰度)
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray_col = vec3(gray);

    // 2. 混合原色和灰度
    vec3 mixed_gray = mix(tex.rgb, gray_col, gray_strength);

    // 3. 白化（混入白色）
    vec3 whitened = mix(mixed_gray, vec3(1.0), whiteness);

    // 4. 调亮度 (加法)
    vec3 brighted = whitened + vec3(brightness);

    // 5. 调对比度 (以 0.5 为中心缩放)
    vec3 contrasted = (brighted - vec3(0.5)) * contrast + vec3(0.5);

    // 6. 限制颜色范围
    vec3 final_color = clamp(contrasted, vec3(0.0), vec3(1.0));

    // 7. 考虑 modulate
    final_color *= v_modulate.rgb;
    float final_alpha = tex.a * v_modulate.a;

    COLOR = vec4(final_color, final_alpha);
}
