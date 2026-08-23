extends DetectComponent
class_name DetectComponentCactus
## 仙人掌攻击检测组件

## 是否检测到在空中的僵尸
var is_have_zombie_in_sky:=false

signal signal_is_have_zombie_in_sky(value:bool)

## 仙人掌需要遍历是否有在空中的敌人，若有，退出当前循环，若没有，遍历所有敌人
## 最后判断是否可以攻击
func judge_is_have_enemy():
	enemy_can_be_attacked = null
	is_have_zombie_in_sky = false
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			## 还未检测到在空中的僵尸，遍历查看是否有在空中的僵尸
			if not is_have_zombie_in_sky:
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

				## 检测到僵尸
				elif enemy is Zombie000Base:
					var enemy_zombie:Zombie000Base = enemy
					if enemy_zombie.curr_be_attack_status & can_attack_zombie_status:
						enemy_can_be_attacked = enemy_zombie
						if enemy_zombie.curr_be_attack_status == Zombie000Base.E_BeAttackStatusZombie.IsSky:
							is_have_zombie_in_sky = true

	## 发射是否有在空中的僵尸
	signal_is_have_zombie_in_sky.emit(is_have_zombie_in_sky)
	if is_instance_valid(enemy_can_be_attacked):
		signal_can_attack.emit()
		return true
	else:
		signal_not_can_attack.emit()
		return false
