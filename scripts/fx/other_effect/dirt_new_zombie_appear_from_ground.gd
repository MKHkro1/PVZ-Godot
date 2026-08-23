extends Node2D
class_name DirtRiseEffect

@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

## 开始泥土特效
func start_dirt() -> void:
	SoundManager.play_other_SFX("dirt_rise")
	visible = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true

	await gpu_particles_2d_2.finished
	queue_free()


func start_dirt_no_free() -> void:
	visible = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true

	await gpu_particles_2d_2.finished
	visible = false
