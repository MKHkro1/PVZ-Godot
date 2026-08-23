#ifndef PARTICALS_PARAMATERS_H
#define PARTICALS_PARAMATERS_H

uniform vec3 direction; // 发射方向/角度
uniform float spread; // 发射角度的随机发散区间
uniform float inherit_emitter_velocity_ratio = 0.0; // 粒子速度的继承系数
uniform vec3 velocity_pivot = vec3(0.0); // 径向速度的参考中心点（枢轴点）
uniform vec3 gravity; // 重力
uniform float collision_friction; // 摩擦系数
uniform float collision_bounce; // 弹性系数
uniform bool collision_enabled = true;

// DisplayParameters 显示参数
uniform float scale_min = 1.0;                 
uniform float scale_max = 1.0;                  // 粒子缩放
uniform float hue_variation_min;         
uniform float hue_variation_max;          // 色调旋转角度
uniform float anim_speed_min;
uniform float anim_speed_max;             // 动画速度
uniform float anim_offset_min;
uniform float anim_offset_max;            // 动画偏移
uniform float lifetime_randomness;        // 粒子生命周期
uniform vec4 color_value : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // 颜色值

// DynamicsParameters 动力学参数
uniform float initial_angle_min; 
uniform float initial_angle_max;           // 初始角度
uniform float angular_velocity_min;
uniform float angular_velocity_max;        // 角速度
uniform float initial_linear_velocity_min;
uniform float initial_linear_velocity_max; // 初始速度乘数
uniform float directional_velocity_min;
uniform float directional_velocity_max;    // 方向速度
uniform float radial_accel_min;
uniform float radial_accel_max;            // 径向速度
uniform float orbit_velocity_min;
uniform float orbit_velocity_max;          // 轨道速度


// PhysicalParameters 物理参数
uniform float linear_accel_min;          
uniform float linear_accel_max;           // 线性加速度
uniform float radial_velocity_min;
uniform float radial_velocity_max;        // 径向加速度
uniform float tangent_accel_min;
uniform float tangent_accel_max;          // 切向加速度
uniform float damping_min;
uniform float damping_max;                // 阻尼系数

uniform sampler2D alpha_curve : repeat_disable; // 透明度曲线
uniform sampler2D color_curve : repeat_disable; // 颜色曲线
uniform sampler2D scale_curve : repeat_disable; // 缩放曲线
uniform sampler2D initial_linear_velocity_curve : repeat_disable; // 轨道速度曲线
uniform sampler2D orbit_velocity_curve : repeat_disable; // 轨道速度曲线
uniform sampler2D angular_velocity_texture : repeat_disable; // 角度速度曲线
uniform vec3 emission_shape_offset = vec3(0.0); 
uniform float emission_shape_scale = 0.0;
uniform float emission_sphere_radius = 0.0;

#endif