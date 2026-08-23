extends Node2D
class_name ZombieDeathBomb

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2


func activate_it():
	reparent(owner.get_parent())
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true

	await gpu_particles_2d.finished
	await gpu_particles_2d_2.finished

	queue_free()
