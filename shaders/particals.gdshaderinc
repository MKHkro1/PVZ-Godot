#ifndef PARTICALS_H
#define PARTICALS_H

#include "particals_paramaters_structs.gdshaderinc"

vec3 get_random_direction_from_spread(inout uint alt_seed, float spread_angle){
    float spread_rad = spread_angle * PI / 180.0; // 角度转弧度

    // 计算随机偏移角度（[-spread_rad, spread_rad]范围）
    float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;

    // 基础方向角计算
    angle1_rad += direction.x != 0.0 ?
                  atan(direction.y, direction.x):
                  sign(direction.y) * (PI / 2.0);

    // 构造方向向量（2D平面）
    return vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
}

// 计算粒子初始位置
vec3 calculate_initial_position(inout DisplayParameters params, inout uint alt_seed) {
	vec3 pos = vec3(0.0);
	{ // Emission shape.
		float s = rand_from_seed(alt_seed) * 2.0 - 1.0;
		float t = rand_from_seed(alt_seed) * 2.0 * PI;
		float radius = emission_sphere_radius * sqrt(1.0 - s * s);
		pos = vec3(radius * cos(t), radius * sin(t), emission_sphere_radius * s);
	}
	return pos * emission_shape_scale + emission_shape_offset;
}

// 黑匣子函数，不要深究
// 色调旋转
vec4 rotate_hue(vec4 current_color, float hue_rot_angle) {
/**
 * 在RGB颜色空间进行色调旋转
 *
 * @param current_color 当前RGBA颜色值
 * @param hue_rot_angle 色调旋转角度（弧度）
 * @return vec4 旋转色调后的新颜色
 *
 * 原理：将RGB颜色分解为亮度(Y)和色度(CbCr)分量，在色度平面进行旋转，
 *       然后重新组合为RGB颜色，保持亮度不变
 */
    // 计算旋转角度的正弦和余弦值
    float hue_rot_c = cos(hue_rot_angle);
    float hue_rot_s = sin(hue_rot_angle);

    /**
     * 构建色调旋转矩阵（4x4，包含RGB和Alpha通道）
     * 矩阵由三个分量组成：
     * 1. 亮度保持矩阵（恒等部分）
     * 2. 色度余弦分量矩阵
     * 3. 色度正弦分量矩阵
     */
    mat4 hue_rot_mat =
        // 分量1：亮度保持矩阵 - 保留RGB中的亮度分量
        mat4(
            vec4(0.299, 0.587, 0.114, 0.0),  // 亮度提取系数（红色通道）
            vec4(0.299, 0.587, 0.114, 0.0),  // 亮度提取系数（绿色通道）
            vec4(0.299, 0.587, 0.114, 0.0),  // 亮度提取系数（蓝色通道）
            vec4(0.000, 0.000, 0.000, 1.0)   // Alpha通道保持不变
        ) +

        // 分量2：色度余弦分量矩阵 - 处理色度平面上的余弦旋转
        mat4(
            vec4(0.701, -0.587, -0.114, 0.0),  // 红色通道的余弦分量
            vec4(-0.299, 0.413, -0.114, 0.0),  // 绿色通道的余弦分量
            vec4(-0.300, -0.588, 0.886, 0.0),  // 蓝色通道的余弦分量
            vec4(0.000, 0.000, 0.000, 0.0)     // Alpha通道无影响
        ) * hue_rot_c +  // 乘以余弦值

        // 分量3：色度正弦分量矩阵 - 处理色度平面上的正弦旋转
        mat4(
            vec4(0.168, 0.330, -0.497, 0.0),   // 红色通道的正弦分量
            vec4(-0.328, 0.035, 0.292, 0.0),   // 绿色通道的正弦分量
            vec4(1.250, -1.050, -0.203, 0.0),  // 蓝色通道的正弦分量
            vec4(0.000, 0.000, 0.000, 0.0)      // Alpha通道无影响
        ) * hue_rot_s;   // 乘以正弦值

    // 应用旋转矩阵并返回新颜色
    return hue_rot_mat * current_color;
}

void process_display_param(inout DisplayParameters parameters, float lifetime) {
	// Compile-time add textures.
	parameters.color.a *= texture(alpha_curve, vec2(lifetime)).r;
	
	parameters.color.rgb *= texture(color_curve, vec2(lifetime)).xyz;
	parameters.color = rotate_hue(parameters.color, parameters.hue_rotation);
}

// 黑匣子函数，不要深究
// 轨道位移
vec3 process_orbit_displacement(
	DynamicsParameters param,
	float lifetime,
	inout uint alt_seed,
	mat4 transform,
	mat4 emission_transform,
	float delta,
	float total_lifetime
	) {
    // 短路优化：速度接近0或时间增量小时直接返回
    if (abs(param.orbit_velocity) < 0.01 || delta < 0.001) {
        return vec3(0.0);
    }

    vec3 displacement = vec3(0.0);
    float pi = 3.14159;
    float orbit_amount = param.orbit_velocity;
    orbit_amount *= texture(orbit_velocity_curve, vec2(lifetime)).r;
    if (orbit_amount != 0.0) {
        // 获取当前粒子位置和发射器原点
        vec3 pos = transform[3].xyz;
        vec3 org = emission_transform[3].xyz;

        // 计算位置差向量
        vec3 diff = pos - org;

        // 计算旋转角度（弧度）
        // orbit_velocity: 每秒完整旋转圈数
        // 角度 = 圈速 × 2π × 时间增量
        float ang = orbit_amount * pi * 2.0 * delta;

        // 创建2D旋转矩阵（绕Z轴）
        mat2 rot = mat2(
            vec2(cos(ang), -sin(ang)),
            vec2(sin(ang), cos(ang))
        );

        // 应用旋转：先减去原始位置，再加回旋转后位置
        displacement.xy -= diff.xy;
        displacement.xy += rot * diff.xy;
    }

    // 将位移转换到世界空间并返回
    return (emission_transform * vec4(displacement / delta, 0.0)).xyz;
}
// 黑匣子函数，不要深究
// 径向位移
vec3 process_radial_displacement(
    DynamicsParameters param,
    float lifetime,
    inout uint alt_seed,
    mat4 transform,
    mat4 emission_transform,
    float delta
	) {
    vec3 radial_displacement = vec3(0.0);

    // 短路优化：时间增量小时直接返回
    if (delta < 0.001) {
        return radial_displacement;
    }

    // 计算全局枢轴点（发射器的速度中心）
    vec3 global_pivot = (emission_transform * vec4(velocity_pivot, 1.0)).xyz;

    // 计算粒子到枢轴点的向量
    vec3 to_pivot = transform[3].xyz - global_pivot;
    float distance_to_pivot = length(to_pivot);

    if (distance_to_pivot > 0.01) {
        // 沿粒子->枢轴点方向移动
        radial_displacement = normalize(to_pivot) * param.radial_velocity;
    } else {
        // 当粒子接近中心时，随机生成方向
        radial_displacement = get_random_direction_from_spread(alt_seed, 360.0) * param.radial_velocity;
    }

    // 特殊处理：防止向内的速度导致闪烁
    if (param.radial_velocity < 0.0) {
        // 计算最大允许位移（不超过到中心的距离）
        float max_displacement = distance_to_pivot / delta;
        radial_displacement = normalize(radial_displacement) *
                             min(abs(param.radial_velocity), max_displacement);
    }

    return radial_displacement;
}



#endif