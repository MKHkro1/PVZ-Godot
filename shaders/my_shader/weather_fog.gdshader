shader_type canvas_item;

//可选的渲染模式：unshaded表示忽略光照计算
//render_mode unshaded;

// 噪声纹理参数: repeat_enable: 允许纹理重复,filter_nearest: 使用最近邻过滤（像素风格）
uniform sampler2D noise_texture: repeat_enable, filter_nearest;
// 雾密度
uniform float density: hint_range(0.0, 1.0) = 0.25;
// 雾移动速度
uniform vec2 speed = vec2(0.02, 0.01);


void fragment() {
	// 计算动态UV坐标：原始UV + 速度 × 时间,这使得雾效能够随时间流动
	vec2 uv = UV + speed * TIME;
	// 从纹理采样红色通道值（灰度值）
	float noise = texture(noise_texture, uv).r;

	//	转换噪声值范围：这增强了噪声的对比度
	float fog = clamp(noise * 2.0 - 1.0, 0.0, 1.0);
	// 应用雾效
	COLOR.a *= fog * density;
}
