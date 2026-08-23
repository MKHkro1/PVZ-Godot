shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform vec2 speed = vec2(0.01, 0.01);
uniform vec4 fog_color : source_color = vec4(0.6, 0.6, 0.6, 1.0);
uniform float intensity_scale = 1.0;
uniform float time_offset = 0.0;

uniform float start_pos_x = 0.2;
uniform float end_pos_x = 0.1;
uniform float start_pos_y = 0.1;
uniform float end_pos_y = 0.05;

uniform float color_variation = 0.3;
uniform float edge_perturb = 0.05;

// 方形遮罩参数
const int MAX_RECTS = 16;
uniform vec2 rect_centers[MAX_RECTS];
uniform vec2 rect_sizes[MAX_RECTS];
uniform float rect_rotations[MAX_RECTS];
uniform int rect_count;

// 新增扰动参数
uniform float rect_perturb_amount = 0.01; // 扰动强度
uniform float rect_perturb_scale = 10.0;  // 扰动比例
uniform float rect_perturb_speed = 0.1;   // 扰动速度

void fragment() {
    // 噪声计算
    vec2 uv1 = UV + (TIME + time_offset) * speed;
    float noise = texture(noise1, uv1).r;
    float noise_alpha = smoothstep(0.2, 1.0, noise * intensity_scale);

    // 渐变控制 + 边缘扰动
    float offset_x = (noise - 0.5) * 2.0 * edge_perturb;
    float offset_y = (noise - 0.5) * 2.0 * edge_perturb;

    float x_ratio = smoothstep(start_pos_x + offset_x, end_pos_x, UV.x);
    float gradient_alpha_x = 1.0 - x_ratio;

    float y_ratio = smoothstep(start_pos_y + offset_y, end_pos_y, UV.y);
    float gradient_alpha_y = 1.0 - y_ratio;

    // 方形遮罩叠加
    float rect_alpha = 1.0;
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= rect_count) break;

        // 获取方形参数
        vec2 center = rect_centers[i];
        vec2 size = rect_sizes[i];
        float rotation = rect_rotations[i];

        // 计算扰动偏移
        vec2 perturb_uv = UV * rect_perturb_scale + TIME * rect_perturb_speed;
        float perturb = texture(noise1, perturb_uv).r;
        perturb = (perturb - 0.5) * 2.0 * rect_perturb_amount;

        // 应用扰动到中心点
        center += vec2(perturb, perturb);

        // 计算旋转后的局部坐标
        vec2 local = UV - center;
        local = vec2(
            local.x * cos(rotation) - local.y * sin(rotation),
            local.x * sin(rotation) + local.y * cos(rotation)
        );
		// 计算到方形边缘的距离
		//vec2 dist = abs(local) - size;  // 使用完整尺寸计算
		//float max_dist = max(dist.x, dist.y);
		vec2 d = abs(local) - size;
		float sdf_dist = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);

		// 边缘过渡参数
		float min_size = min(size.x, size.y);
		float edge_width = 0.05; // 过渡区为0.05

		//float inner_threshold = -edge_width;  // 内过渡开始
		// 若本身区域小于0.05，设置内过度区域为原始大小的1/3
		float inner_threshold = min_size < 0.05 ? -min_size/5.0 : -edge_width;  // 阈值0.1可调
		float outer_threshold = edge_width;   // 外过渡结束

		// 双向平滑过渡：
		// max_dist < inner_threshold → 完全透明 (0.0)
		// inner_threshold → outer_threshold → 平滑过渡 (0.0→1.0)
		// max_dist > outer_threshold → 完全不透明 (1.0)
		float alpha_i = smoothstep(inner_threshold, outer_threshold, sdf_dist);
		rect_alpha *= alpha_i;
    }

    // 最终alpha
    float final_alpha = noise_alpha * gradient_alpha_x * gradient_alpha_y * rect_alpha;

    // 色彩扰动
    vec3 varied_color = fog_color.rgb - (noise - 0.5) * 1.0 * color_variation;
    varied_color = clamp(varied_color, 0.0, 1.0);

    COLOR.rgb = varied_color;
    COLOR.a = fog_color.a * final_alpha;
}