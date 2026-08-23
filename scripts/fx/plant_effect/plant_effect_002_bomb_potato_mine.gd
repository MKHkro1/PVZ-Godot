extends BombEffectBase
class_name BombEffectPotatoMine

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

# 樱桃炸弹爆炸特效
func activate_bomb_effect():
	super()
	gpu_particles_2d.emitting = true

	await gpu_particles_2d.finished
	queue_free()
