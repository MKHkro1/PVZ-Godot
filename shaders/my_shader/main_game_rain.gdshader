// simple rain/snow shader
// useful learning resources:
// https://www.ronja-tutorials.com/post/034-2d-sdf-basics/#circle
// https://iquilezles.org/articles/distfunctions2d/

shader_type canvas_item;

// 雨 / 雪 shader 的可调参数（uniforms）：

// 雨线 /雪线的数量 (条数)
// count 越大：线越多，雨 /雪越密集。
// 范围：0〜2000，默认 150
uniform int count: hint_range(0, 2000) = 1000;

// 倾斜 (slant)：线条在 x 方向相对于 y 方向的偏斜程度（模拟风向）
// 如果是负值 (比如 -0.01)，雨 /雪线向左倾斜；正值则向右。
// 范围 -0.1 ~ 0.1，默认 -0.01
uniform float slant: hint_range(-0.1, 0.1) = 0.05;

// 下落速度 (speed)：控制线条 (雨 / 雪) 在 y 方向 (或倾斜方向) 的移动速度
// 值越大，下落越快，动画更迅速。
// 范围 0.0 ~ 100.0，默认 50.0
uniform float speed: hint_range(0.0, 100.0) = 15.0;

// 模糊 (blur)：控制雨 /雪线条边缘的柔和度。
// blur 值越小，线越锐利；值越大，线越模糊 (边缘更平滑)。
// 范围 0.0005 ~ 0.1，默认 0.002
uniform float blur: hint_range(0.0005, 0.1) = 0.002;

// 线条 (雨 /雪) 的颜色 (RGBA)
// colour 的 RGB 控制线条颜色 (例如白色、淡蓝等)，A 通常控制透明度 (在 shader 里又乘上其他值)。
// 默认是纯白 (1.0, 1.0, 1.0) 和 alpha = 1.0。
uniform vec4 colour: source_color = vec4(1.0, 1.0, 1.0, 1.0);

// 线条 (雨 /雪) 的 “半尺寸” (size)：控制线条宽度和长度 (在 UV 空间中)。
// size.x 控制宽度 (条纹粗细)；size.y 控制线条长度 (条纹长度)。
// 默认是 vec2(0.005, 0.2)：非常窄 (0.005)，但是比较长 (0.2)，适合雨线。
uniform vec2 size = vec2(0.008, 0.05);

float line_sdf(vec2 p, vec2 s) {
    vec2 d = abs(p) - s;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float Hash(float x) {
    return fract(sin(x * 18.34) * 51.78);
}

float Hash2(float x) {
    return fract(sin(x * 25.42) * 21.24);
}

void fragment() {
	// inspector issue with tiny vec 2
    vec2 s = size * 0.1;
	// to work at the start
    float time = TIME + 1000.0;
    vec2 uv = UV;
	// slant each line left or right
    uv.x += uv.y * slant;
    float output = 0.0;
    
    for (int i = 1; i <= count; i++) {
        float h1 = Hash(float(i));
        float h2 = Hash2(float(i));
		// make it so the lines move in the direction of the slant as well
		// otherwise they would go directly down no matter what slant is
        float sl = h1 * uv.y * -slant;
		// compute random x position of line, multiply by 1.2 to cover the far edges more predictably
        float pos_mod_x = h1 * 1.2;
		// there is probably better way to do this, to prevent line from moving too slow compared to other lines
        float pos_mod_y = max(h2 * speed, pos_mod_x * speed);
		// wrap y values around to loop the anim
        vec2 position = vec2(pos_mod_x + sl, -mod(-pos_mod_y * time * 0.1, -1.));
        float sdf = line_sdf(uv - position, s);
        output += clamp(- sdf / blur, 0.0, 1.0);
    }

    COLOR = vec4(colour.rgb, output);
}
