extends BulletEffect000Base
class_name BulletEffect001Norm
## 通用子弹(普通子弹)特效

@onready var all_particles_2d: Node2D = $AllParticles2D
@onready var splats: Sprite2D = get_node_or_null(^"Splats")

func activate_bullet_effect():
	super()
	visible = true
	for gpu_particles_2d in all_particles_2d.get_children():
		gpu_particles_2d.emitting = true
	await get_tree().create_timer(0.2).timeout
	if splats:
		splats.visible = false
	if all_particles_2d.get_child_count() != 0:
		await get_tree().create_timer(all_particles_2d.get_child(0).lifetime).timeout
	queue_free()
