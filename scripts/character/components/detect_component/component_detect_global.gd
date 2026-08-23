extends DetectComponent
class_name DetectComponentGlobal
## 全局检测组件
## 追踪子弹检测敌人使用,挂载在MainGame中


func _process(_delta):
	if need_judge and is_enabling:
		need_judge = false
		if judge_is_have_enemy():
			update_enemy_track_bullet()


## 更新敌人 enemy_can_be_attacked,追踪型子弹
##TODO: 全局子弹判定敌人(植物)
"""
追踪子弹首次检测敌人直接锁定,直到敌人死亡,在选择下一个敌人
第一次索敌时有空中敌人先攻击空中敌人
选择敌人时按照靠近房子的顺序选择
发射子弹的植物,若前一格有敌人,优先索敌前一格敌人,不使用全局索敌
"""
func update_enemy_track_bullet() -> Character000Base:
	## 所有的可以攻击的敌人
	var all_enemy_can_be_attacked:Array[Character000Base] = get_all_enemy_can_be_attacked()
	## 是否有空中敌人
	var is_have_sky_enemy:= false
	for enemy:Character000Base in all_enemy_can_be_attacked:
		if enemy is Plant000Base:
			pass
		elif enemy is Zombie000Base:
			## 敌人已经死亡
			if not is_instance_valid(enemy_can_be_attacked):
				enemy_can_be_attacked = enemy
				if enemy.curr_be_attack_status == Zombie000Base.E_BeAttackStatusZombie.IsSky:
					is_have_sky_enemy = true
				continue
			## 如果有在空中的敌人,只对空中敌人进行判定
			if is_have_sky_enemy:
				if enemy.curr_be_attack_status == Zombie000Base.E_BeAttackStatusZombie.IsSky:
					if enemy_can_be_attacked.global_position.x > enemy.global_position.x:
						enemy_can_be_attacked = enemy
			else:
				## 先判断是否为空中敌人
				if enemy.curr_be_attack_status == Zombie000Base.E_BeAttackStatusZombie.IsSky:
					is_have_sky_enemy = true
					enemy_can_be_attacked = enemy
				else:
					if enemy_can_be_attacked.global_position.x > enemy.global_position.x:
						enemy_can_be_attacked = enemy

	return enemy_can_be_attacked

