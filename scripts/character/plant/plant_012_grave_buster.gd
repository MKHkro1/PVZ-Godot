extends Plant000Base
class_name Plant012GraveBuster

@onready var gpu_particles_2d_grave_buster: GPUParticles2D = %GPUParticles2DGraveBuster

var is_end_eat_grave := false

func ready_norm():
	super()
	_start_eat_grave()

## 植物死亡
func character_death():
	super()
	## 角色死亡时是否已经吞噬墓碑完成
	if not is_end_eat_grave:
		if not is_instance_valid(plant_cell.tombstone):
			print("当前植物格子", plant_cell.row_col, "没有墓碑")
			return
		plant_cell.tombstone.failure_eat_tombstone()

## 开始吞噬墓碑
func _start_eat_grave():
	## 播放音效
	SoundManager.play_character_SFX(&"GraveBusterChomp")

	await get_tree().create_timer(0.5).timeout
	gpu_particles_2d_grave_buster.emitting = true
	gpu_particles_2d_grave_buster.visible = true
	if not is_instance_valid(plant_cell.tombstone):
		print("当前植物格子", plant_cell.row_col, "没有墓碑")
		return
	plant_cell.tombstone.start_be_grave_buster_eat()

## 吞噬墓碑结束
func _end_eat_grave():
	is_end_eat_grave = true
	#GlobalUtils.child_node_change_parent(gpu_particles_2d_grave_buster, plant_cell)
	gpu_particles_2d_grave_buster.reparent(plant_cell)
	gpu_particles_2d_grave_buster.emitting = false
	## 两秒后删除自身
	gpu_particles_2d_grave_buster.free_self_after_two_sec()

	if not is_instance_valid(plant_cell.tombstone):
		print("当前植物格子", plant_cell.row_col, "没有墓碑")
		return
	plant_cell.tombstone.tombstone_death()

