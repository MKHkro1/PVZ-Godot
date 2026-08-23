shader_type canvas_item;
render_mode blend_mix;  // 确保启用混合模式

// 波纹参数
uniform float ripple_speed : hint_range(0, 0.5) = 0.1;
uniform float ripple_scale : hint_range(0.1, 10.0) = 3.0;
uniform float ripple_strength : hint_range(0, 0.1) = 0.03;
uniform float ripple_blur : hint_range(0, 1) = 0.4;

// 水颜色参数
uniform vec4 water_color : source_color = vec4(0.2, 0.5, 0.8, 0.6);
uniform float color_blend : hint_range(0, 1) = 0.5;
uniform float alpha : hint_range(0, 1) = 1.0;  // 新增透明度控制

// 随机函数
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// 简化版噪声函数
float simple_noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    // 四个角落的随机值
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    // 双线性插值
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
          (c - a) * u.y * (1.0 - u.x) +
          (d - b) * u.x * u.y;
}

void fragment() {
    // 获取原始纹理颜色
    vec4 original_color = texture(TEXTURE, UV);

    // 创建基于噪声的波纹UV坐标
    vec2 ripple_uv = UV;

    // 使用噪声纹理或生成噪声
    vec2 noise_uv = UV * ripple_scale;
    noise_uv.x += TIME * ripple_speed;
    noise_uv.y += TIME * ripple_speed * 0.7;

    float noise_value = simple_noise(noise_uv);

    // 创建有机形状的波纹区域
    float ripple_mask = smoothstep(0.3, 0.7, noise_value);

    // 添加动态变化
    float time_factor = sin(TIME * 0.5) * 0.5 + 0.5;
    ripple_mask *= time_factor;

    // 计算波纹位移方向
    vec2 noise_uv2 = UV * (ripple_scale * 1.3) + vec2(TIME * 0.2, TIME * 0.15);
    float noise_x = simple_noise(noise_uv2);
    float noise_y = simple_noise(noise_uv2 + vec2(5.2, 3.3));

    // 应用有机形状的波纹位移
    vec2 ripple_offset = vec2(
        (noise_x - 0.5) * 2.0,
        (noise_y - 0.5) * 2.0
    ) * ripple_strength * ripple_mask;

    ripple_uv += ripple_offset;

    // 应用模糊效果使过渡更平滑
    vec4 rippled_color = texture(TEXTURE, ripple_uv);
    vec4 blurred_color = texture(TEXTURE, ripple_uv + vec2(ripple_blur * 0.01, 0.0));
    blurred_color += texture(TEXTURE, ripple_uv + vec2(-ripple_blur * 0.01, 0.0));
    blurred_color += texture(TEXTURE, ripple_uv + vec2(0.0, ripple_blur * 0.01));
    blurred_color += texture(TEXTURE, ripple_uv + vec2(0.0, -ripple_blur * 0.01));
    rippled_color = mix(rippled_color, blurred_color / 4.0, ripple_blur * ripple_mask);

    // 混合水颜色
    vec4 final_color = mix(rippled_color, water_color, color_blend);

    // 添加有机形状的高光效果
    float highlight = ripple_mask * (0.3 + 0.2 * sin(TIME * 1.5 + noise_value * 10.0));
    final_color.rgb += vec3(highlight * 0.3);

    // 添加微妙的颜色变化
    final_color.rgb *= 1.0 + (noise_value - 0.5) * 0.1;

    // 应用透明度
    final_color.a *= alpha;

    COLOR = final_color;
}