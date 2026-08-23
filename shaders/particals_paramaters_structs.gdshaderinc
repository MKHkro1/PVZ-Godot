#ifndef PARTICALS_PARAMATERS_STRUCTS_H
#define PARTICALS_PARAMATERS_STRUCTS_H
#include "random_seed.gdshaderinc"
#include "particals_paramaters.gdshaderinc"
// 显示参数结构体
struct DisplayParameters {
	vec3 scale;                      // 粒子缩放
	float hue_rotation;              // 色调旋转角度
	float animation_speed;           // 动画速度
	float animation_offset;          // 动画偏移
	float lifetime;                  // 粒子生命周期
	vec4 color;                      // 基础颜色
	float emission_texture_position; // 发射纹理位置（保留字段）
};

void calculate_initial_display_params(
	inout DisplayParameters params, // 参数结构体
	inout uint alt_seed, // 种子
	){
	// 缩放随机化（确保最小缩放不为零）
	params.scale = vec3(mix(scale_min, scale_max, rand_from_seed(alt_seed)));
	params.scale = sign(params.scale) * max(abs(params.scale), 0.001);
	
	// 色调旋转（转换为弧度）
	params.hue_rotation = PI * 2.0 * mix(hue_variation_min, hue_variation_max, rand_from_seed(alt_seed));
	
	// 动画参数
	params.animation_speed = mix(anim_speed_min, anim_speed_max, rand_from_seed(alt_seed));
	params.animation_offset = mix(anim_offset_min, anim_offset_max, rand_from_seed(alt_seed));
	
	// 生命周期（考虑随机性）
	params.lifetime = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
	
	// 基础颜色
	params.color = color_value;
}

// 动力学参数结构体
struct DynamicsParameters {
	float angle;                       // 初始角度
	float angular_velocity;            // 角速度
	float initial_velocity_multiplier; // 初始速度乘数
	float directional_velocity;        // 方向性速度
	float radial_velocity;             // 径向速度
	float orbit_velocity;              // 轨道速度
};

void calculate_initial_dynamics_params(
	inout DynamicsParameters params,
	inout uint alt_seed,
	){
	// 角度和角速度
	params.angle = mix(initial_angle_min, initial_angle_max, rand_from_seed(alt_seed));
	params.angular_velocity = mix(angular_velocity_min, angular_velocity_max, rand_from_seed(alt_seed));
	
	// 各类速度参数
	params.initial_velocity_multiplier = mix(initial_linear_velocity_min, initial_linear_velocity_max, rand_from_seed(alt_seed));
	params.directional_velocity = mix(directional_velocity_min, directional_velocity_max, rand_from_seed(alt_seed));
	params.radial_velocity = mix(radial_velocity_min, radial_velocity_max, rand_from_seed(alt_seed));
	params.orbit_velocity = mix(orbit_velocity_min, orbit_velocity_max, rand_from_seed(alt_seed));
}

// 物理参数结构体
struct PhysicalParameters {
	float linear_accel;          // 线性加速度
	float radial_accel;          // 径向加速度
	float tangent_accel;         // 切向加速度
	float damping;               // 阻尼系数
};

void calculate_initial_physical_params(
	inout PhysicalParameters params,
	inout uint alt_seed
	)
{
	// 线性加速度
	params.linear_accel = mix(linear_accel_min, linear_accel_max, rand_from_seed(alt_seed));
	// 径向加速度
	params.radial_accel = mix(radial_accel_min, radial_accel_max, rand_from_seed(alt_seed));
	// 切向加速度
	params.tangent_accel = mix(tangent_accel_min, tangent_accel_max, rand_from_seed(alt_seed));
	// 切向加速度
	params.damping = mix(damping_min, damping_max, rand_from_seed(alt_seed));
}

void calculate_initial_all_params(
	inout DisplayParameters display_params,
	inout DynamicsParameters dynmics_paras,
	inout PhysicalParameters physics_params,
	inout uint alt_seed
	)
{
	calculate_initial_display_params(display_params, alt_seed);
	calculate_initial_dynamics_params(dynmics_paras, alt_seed);
	calculate_initial_physical_params(physics_params, alt_seed);
}

#endif