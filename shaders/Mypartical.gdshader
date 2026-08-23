shader_type particles;

#include "public.gdshaderinc"
#include "particals.gdshaderinc"

uniform vec3 random_direction_from_spread;

void start()
{
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	DisplayParameters display_params;
	DynamicsParameters dynamic_params;
	PhysicalParameters physics_params;

	calculate_initial_all_params(display_params, dynamic_params, physics_params, alt_seed); // 初始化帧数据
	process_display_param(display_params, 0.0);
	if (rand_from_seed(alt_seed) > AMOUNT_RATIO)    ACTIVE = false; // 如果随机数小于发射比率，则粒子隐藏
	if (RESTART_CUSTOM)
	{
		CUSTOM = vec4(0.0);
		CUSTOM.w = display_params.lifetime;
		CUSTOM.x = dynamic_params.angle;
	}
	// 颜色初始化
	if (RESTART_COLOR)    COLOR = display_params.color;
	// 旋转和缩放重置
	if (RESTART_ROT_SCALE)
	{
		TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
		TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
		TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);
	}
	// 位置初始化
	if (RESTART_POSITION) {
		TRANSFORM[3].xyz = calculate_initial_position(display_params, alt_seed); // 生成局部坐标
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM; // 通过EMISSION_TRANSFORM转换为全局坐标
	}
	if (RESTART_VELOCITY)    VELOCITY = get_random_direction_from_spread(alt_seed, spread) * dynamic_params.initial_velocity_multiplier;

	VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz; // 将局部空间速度转换为世界空间速度
	VELOCITY += EMITTER_VELOCITY * inherit_emitter_velocity_ratio; // 当发射器移动时，新生成的粒子获得发射器部分速度，模拟现实中的运动参照系转换

	VELOCITY.z = 0.0; TRANSFORM[3].z = 0.0; // 强制粒子在XY平面运动（2D粒子系统）
}

void process() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	DisplayParameters display_params;
	DynamicsParameters dynamic_params;
	PhysicalParameters physics_params;

	calculate_initial_all_params(display_params, dynamic_params, physics_params, alt_seed); // 初始化帧数据

	// 更新粒子已存活时间（标准化值：0.0=出生，1.0=生命周期结束）
	CUSTOM.y += DELTA / LIFETIME; // DELTA=帧时间，LIFETIME=粒子系统总时长
	CUSTOM.y = mix(CUSTOM.y, 1.0, INTERPOLATE_TO_END); // 平滑过渡到生命周期结束（INTERPOLATE_TO_END是引擎提供的混合因子）
	float lifetime_percent = CUSTOM.y / display_params.lifetime; // 计算当前生命周期进度百分比 (0.0-1.0), 含随机性
	if (CUSTOM.y > CUSTOM.w)    ACTIVE = false; // 检查粒子是否超过预设生命周期（CUSTOM.w存储初始生命周期）

	process_display_param(display_params, lifetime_percent);

	// ===== 3. 位移计算 =====
	vec3 controlled_displacement = vec3(0.0);  // 非物理控制的位移
	{
		// 3.1 轨道位移：粒子围绕发射器中心旋转
	    controlled_displacement += process_orbit_displacement(
	        dynamic_params,
	        lifetime_percent,
	        alt_seed,
	        TRANSFORM,              // 当前粒子变换矩阵
	        EMISSION_TRANSFORM,     // 发射器变换矩阵
	        DELTA,                  // 帧时间
	        display_params.lifetime * LIFETIME // 总生命周期
	    );

		// 3.2 径向位移：粒子朝向/背离发射器中心移动
	    controlled_displacement += process_radial_displacement(
	        dynamic_params,
	        lifetime_percent,
	        alt_seed,
	        TRANSFORM,
	        EMISSION_TRANSFORM,
	        DELTA
	    );
	}
	// ===== 4. 物理模拟 =====
	VELOCITY = normalize(VELOCITY) * dynamic_params.initial_velocity_multiplier;
	VELOCITY *= texture(initial_linear_velocity_curve, vec2(lifetime_percent)).r;
    // 4.1 力计算（组合所有作用力）
	vec3 force;
    {
        // 基础重力
        force = gravity;

        vec3 pos = TRANSFORM[3].xyz;  // 当前粒子位置
        vec3 org = EMISSION_TRANSFORM[3].xyz;  // 发射器原点

        // 线性加速度：沿当前速度方向加速
        force += length(VELOCITY) > 0.0 ?
                 normalize(VELOCITY) * physics_params.linear_accel :
                 vec3(0.0);

        // 径向加速度：沿粒子->发射器中心方向加速
        vec3 diff = pos - org;
        force += length(diff) > 0.0 ?
                 normalize(diff) * physics_params.radial_accel :
                 vec3(0.0);

        // 切向加速度：垂直于径向方向（2D平面旋转）
        force += length(diff.yx) > 0.0 ?
                 vec3(normalize(diff.yx * vec2(-1.0, 1.0)), 0.0) * physics_params.tangent_accel :
                 vec3(0.0);

        // 添加外部吸引力（如力场）
        force += ATTRACTOR_FORCE;

        // 强制2D平面（锁定Z轴）
        force.z = 0.0;

        // 应用力到速度（经典物理：F=ma -> Δv = F/m * t，此处质量视为1）
        VELOCITY += force * DELTA;
    }
	// 4.2 阻尼应用（速度衰减）
    {
        if (physics_params.damping > 0.0) {
            float v = length(VELOCITY);  // 当前速度标量

            // 应用阻尼衰减（指数衰减模型）
            v -= physics_params.damping * DELTA;

            // 速度归零处理
            if (v < 0.0) {
                VELOCITY = vec3(0.0);
            } else {
                // 保持方向，应用衰减后速度
                VELOCITY = normalize(VELOCITY) * v;
            }
        }
    }
	// ===== 5. 碰撞响应 =====
	{
		if (COLLIDED && collision_enabled) {  // 引擎检测到碰撞时触发
			// 1. 计算碰撞法线方向的速度分量
			float collision_response = dot(COLLISION_NORMAL, VELOCITY);

			// 2. 反弹触发阈值计算
			float slide_to_bounce_trigger = step(
				2.0 / clamp(collision_bounce + 1.0, 1.0, 2.0),
				abs(collision_response)
			);

		    // 3. 位置修正：解决穿透问题
		    TRANSFORM[3].xyz += COLLISION_NORMAL * COLLISION_DEPTH;

		    // 4. 速度分解：移除法向分量
		    VELOCITY -= COLLISION_NORMAL * collision_response;

		    // 5. 应用摩擦力
		    VELOCITY = mix(VELOCITY, vec3(0.0), clamp(collision_friction, 0.0, 1.0));

		    // 6. 应用反弹
		    VELOCITY -= COLLISION_NORMAL * collision_response * (collision_bounce * slide_to_bounce_trigger);
		}
	}
	// ===== 6. 位置更新 =====
    // 组合最终速度 = 受控位移 + 物理速度
    vec3 final_velocity = controlled_displacement + VELOCITY;
    // 强制2D平面（锁定Z轴）
    final_velocity.z = 0.0;
    // 更新粒子位置：s = s0 + v*t
    TRANSFORM[3].xyz += final_velocity * DELTA;

	// 采样当前角速度系数
	float ang_vel_factor = texture(angular_velocity_texture, vec2(lifetime_percent)).r;

	// 计算角速度(弧度/秒)
	float angular_velocity_rad = dynamic_params.angular_velocity * (3.14159/180.0);

	// 增量旋转 = 角速度 × 时间 × 纹理系数
	CUSTOM.x += angular_velocity_rad * DELTA * ang_vel_factor;

	COLOR = display_params.color;
	// 应用旋转
	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	TRANSFORM[3].z = 0.0;

	// 缩放应用（防止零缩放）
	float scale_delta = texture(scale_curve, vec2(lifetime_percent)).r;
	// 检测每个轴的缩放值是否为负
	float scale_sign_x = display_params.scale.x < 0.0 ? -1.0 : 1.0;
	float scale_sign_y = display_params.scale.y < 0.0 ? -1.0 : 1.0;
	float scale_sign_z = display_params.scale.z < 0.0 ? -1.0 : 1.0;
	float scale_minimum = 0.001;
	TRANSFORM[0].xyz *= scale_sign_x * max(abs(display_params.scale.x), scale_minimum) * scale_delta;
	TRANSFORM[1].xyz *= scale_sign_y * max(abs(display_params.scale.y), scale_minimum) * scale_delta;
	TRANSFORM[2].xyz *= scale_sign_z * max(abs(display_params.scale.z), scale_minimum) * scale_delta;

	CUSTOM.z = display_params.animation_offset + lifetime_percent * display_params.animation_speed;

	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}
}
