extends BombEffectBase
class_name BombEffectCherryBomb

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var explosive_font: Sprite2D = $ExplosiveFont

## 樱桃炸弹爆炸特效
func activate_bomb_effect():
	super()
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true

	await get_tree().create_timer(gpu_particles_2d.lifetime/2).timeout
	explosive_font.queue_free()
	await gpu_particles_2d.finished
	queue_free()
