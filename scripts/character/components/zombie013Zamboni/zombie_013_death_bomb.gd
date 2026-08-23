extends Node2D
class_name ZamboniDeathBomb

@onready var body: Node2D = $Body
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2

var is_activate:=false
var _flying_sprites = []

func _process(delta):
	if is_activate:
		for sprite_data in _flying_sprites:
			var node = sprite_data.node
			var vel = sprite_data.velocity
			var rot = sprite_data.angular_speed

			# 更新位置和旋转
			node.global_position += vel * delta
			node.rotation += deg_to_rad(rot) * delta
			# 添加阻力
			sprite_data.velocity = vel.move_toward(Vector2.ZERO, delta * 200)

func activate_it():
	is_activate = true
	visible = true
	explode()
	#GlobalUtils.child_node_change_parent(self, owner.get_parent())
	reparent(owner.get_parent())
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true
	await gpu_particles_2d.finished
	queue_free()

func explode():
	var base_force = 150
	var base_rot = 100  # 最大角速度

	for child in body.get_children():
		if child is Sprite2D:
			# 给它添加炸飞动画（速度、旋转、重力等）
			var dir = Vector2(randf() * 1.5 - 0.75, -1).normalized()
			var force = base_force
			var rot_speed = randf_range(-base_rot, base_rot)

			# 把炸飞行为统一加到动画系统里（如用 Dictionary 存状态）
			_flying_sprites.append({
				"node": child,
				"velocity": dir * force,
				"angular_speed": rot_speed,
			})
