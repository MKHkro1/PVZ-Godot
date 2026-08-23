extends BombEffectBase
class_name BombEffectCobCannon
## 加农炮子弹爆炸特效

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func activate_bomb_effect():
	super()
	gpu_particles_2d.emitting = true

	await gpu_particles_2d.finished
	queue_free()
