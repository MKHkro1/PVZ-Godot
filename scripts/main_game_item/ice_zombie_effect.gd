extends Node2D
class_name IceEffect

@onready var icetrap: Sprite2D = $Icetrap
@onready var icetrap_2: Sprite2D = $Icetrap2
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func start_ice_effect(ice_time:float):
	await get_tree().create_timer(ice_time, false).timeout
	icetrap.visible = false
	icetrap_2.visible = false

	gpu_particles_2d.emitting = true

	await gpu_particles_2d.finished
	queue_free()


