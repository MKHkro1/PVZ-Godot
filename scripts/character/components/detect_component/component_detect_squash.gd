extends DetectComponent
class_name DetectComponentSquash

## 部分僵尸有需要进行倭瓜位置判断,撑杆跳起跳之前在左边时可以攻击
## 如果检测到可以被攻击的敌人，发射信号,保存当前敌人，return,若到最后没有检测到敌人，发射信号，重置当前敌人，return
func judge_is_have_enemy():
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			var enemy:Character000Base = enemy_area.owner
			## 先判断行属性
			if is_lane and owner.lane != enemy.lane:
				continue
			## 如果敌人为植物
			if enemy is Plant000Base:
				var enemy_plant:Plant000Base = enemy
				## 如果当前植物可以被攻击到
				if enemy_plant.curr_be_attack_status & can_attack_plant_status:
					enemy_can_be_attacked = enemy_plant
					signal_can_attack.emit()
					return true

			## 检测到僵尸
			elif enemy is Zombie000Base:
				var enemy_zombie:Zombie000Base = enemy
				if enemy_zombie.curr_be_attack_status & can_attack_zombie_status:
					## 如果触发倭瓜位置判定（撑杆跳、海豚僵尸）
					if enemy_zombie.is_trigger_squash_pos_judge:
						## 敌人在左边
						if enemy_zombie.global_position.x < owner.global_position.x:
							enemy_can_be_attacked = enemy_zombie
							signal_can_attack.emit()
							return true
					else:
						enemy_can_be_attacked = enemy_zombie
						signal_can_attack.emit()
						return true

	enemy_can_be_attacked = null
	signal_not_can_attack.emit()
	return false

