extends Node2D
class_name GardenFlowerPot

@export var down_plant_container:Node2D
@onready var animation_tree: AnimationTree = $AnimationTree

## 是否为水路植物
@export var is_water := false
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var pot_glow: Sprite2D = $Body/BodyCorrect/PotGlow
@onready var pot_glow_2: Sprite2D = $Body/BodyCorrect/PotGlow2

@onready var body: Node2D = $Body


func _ready() -> void:
	var ori_speed = animation_tree.get("parameters/TimeScale/scale")
	var anim_random = randf_range(0.9,1.1)
	animation_tree.set("parameters/TimeScale/scale", ori_speed * anim_random)

## 植物是否为profect
func plant_change_profect(is_profect:bool):
	if is_profect:
		gpu_particles_2d.emitting = true
		if is_water:
			pot_glow.visible = false
			pot_glow_2.visible = true
		else:
			pot_glow.visible = true
			pot_glow_2.visible = false
	else:
		gpu_particles_2d.emitting = false
		pot_glow.visible = false
		pot_glow_2.visible = false

func update_body_visible(curr_is_visible:bool = true):
	body.visible = curr_is_visible
	animation_tree.active = curr_is_visible
