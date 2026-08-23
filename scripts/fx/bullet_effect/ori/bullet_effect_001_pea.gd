extends Node2D
class_name BulletEffect

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@export var splats: Sprite2D

func activate_bullet_effect():
	visible = true
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(0.2).timeout
	if splats:
		splats.visible = false

	await get_tree().create_timer(gpu_particles_2d.lifetime).timeout
	queue_free()
