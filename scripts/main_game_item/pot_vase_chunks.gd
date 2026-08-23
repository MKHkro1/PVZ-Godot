extends Sprite2D
class_name PotVaseChunkDrop

@export var ground_y := 0.0        # 地面位置
@export var gravity := 500.0       # 重力
@export var bounce_damping := 0.5  # 反弹衰减（0.5 = 半）
@export var min_bounce_speed := 30.0 # 最小反弹速度

@export var x_velocity := 0.0      # 水平速度
@export var rotation_speed := 5.0  # 初始旋转速度
@export var rotation_slow := 0.5   # 每秒减少旋转速度量

var velocity := Vector2.ZERO
var is_active := false
var landed := false


func activate_drop():
	# 初始速度
	velocity = Vector2(x_velocity, 0)
	is_active = true


func _process(delta: float) -> void:
	if not is_active or landed:
		return

	# 重力
	velocity.y += gravity * delta

	# 移动 + 旋转
	position += velocity * delta
	rotation += rotation_speed * delta

	# 旋转逐渐变慢
	if abs(rotation_speed) > 0.1:
		if rotation_speed > 0:
			rotation_speed -= rotation_slow * delta
		else:
			rotation_speed += rotation_slow * delta

	# 落地检测
	if position.y >= ground_y and not landed:
		land_on_ground()


func land_on_ground():
	position.y = ground_y

	if abs(velocity.y) > min_bounce_speed:
		# 反弹：反向 + 减弱
		velocity.y = -velocity.y * bounce_damping
	else:
		# 最终落地
		velocity = Vector2.ZERO
		rotation_speed = 0
		landed = true
		fade_and_delete()


func fade_and_delete():
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.8)
