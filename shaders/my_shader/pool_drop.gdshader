shader_type canvas_item;
render_mode blend_mix;

// ---------- 控制参数 ----------
uniform int drop_count : hint_range(0, 16) = 8;
uniform float spawn_rate : hint_range(0.1, 8.0) = 0.5;
uniform float drop_life : hint_range(0.1, 3.0) = 0.9;
uniform float drop_speed : hint_range(0.001, 0.1) = 0.01;
uniform float drop_size : hint_range(0.001, 0.05) = 0.005;
uniform float drop_thickness : hint_range(0.0005, 0.02) = 0.01;
uniform vec4 drop_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float global_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float randomness_seed : hint_range(0.0, 1000.0) = 12.34;
// ------------------------------------------------

// 伪随机
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    float acc = 0.0;

    float wave_id = floor(TIME * spawn_rate); // 当前“生成轮”编号

    for (int i = 0; i < 16; i++) {
        if (i >= drop_count) break;

        float fi = float(i);

        // 每个生成器独立随机 + 每轮刷新
        vec2 base_seed = vec2(fi * 13.7 + randomness_seed,
                              fi * 7.9 + randomness_seed * 2.0);

        // 为了让位置每轮变化，加入 wave_id
        vec2 seed_move = base_seed + wave_id * vec2(3.17, 5.91);

        // 每次生成的位置都会变化
        vec2 drop_center = vec2(
            rand(seed_move),
            rand(seed_move + vec2(6.1, 9.7))
        );

        // 每个生成器自己的相位偏移（避免同步）
        float phase_offset = rand(base_seed + vec2(2.2, 4.4));

        // 0..1 周期
        float life_phase = fract(TIME * spawn_rate + phase_offset);
        float life_ratio = clamp(drop_life * spawn_rate, 0.0, 1.0);

        // 是否在“可见阶段”
        if (life_phase <= life_ratio) {
            float event_t = life_phase / max(0.0001, life_ratio);

            float fade = 1.0 - event_t;

            // 当前半径
            float radius = drop_size + event_t * (drop_speed * 0.25 + 0.06);

            // 与中心距离
            float d = distance(uv, drop_center);

            // 细环线
            float ring = 1.0 - smoothstep(0.0, drop_thickness, abs(d - radius));

            acc += ring * fade;
        }
    }

    acc = clamp(acc, 0.0, 1.0);

    COLOR = vec4(drop_color.rgb, drop_color.a * acc * global_alpha);
}
