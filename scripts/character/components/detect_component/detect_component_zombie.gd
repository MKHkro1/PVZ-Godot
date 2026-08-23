extends DetectComponent
class_name DetectComponentZombie

var brain:BrainOnZombieMode

## 如果检测到可以被攻击的敌人，发射信号,保存当前敌人，return,若到最后没有检测到敌人，发射信号，重置当前敌人，return
func judge_is_have_enemy():
	#print("判定敌人")
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			if enemy_area.owner is BrainOnZombieMode:
				#print("检测到脑子")
				brain = enemy_area.owner
				signal_can_attack.emit()
				return true

			## 非角色类型
			if not enemy_area.owner is Character000Base:
				continue
			var enemy:Character000Base = enemy_area.owner
			if _judge_enemy_is_can_be_attack(enemy):
				enemy_can_be_attacked = enemy
				if enemy_can_be_attacked is Plant000Base and is_instance_valid(enemy_can_be_attacked):
					enemy_can_be_attacked = get_first_be_hit_plant_in_cell(enemy_can_be_attacked)
					if enemy_can_be_attacked == null:
						continue
					enemy_can_be_attacked.signal_character_death.connect(func():need_judge = true)
				signal_can_attack.emit()
				return true

	## 如果循环结束还未return,未找到敌人
	enemy_can_be_attacked = null
	signal_not_can_attack.emit()
	return false
