extends BombComponentBase
class_name BombComponentNorm
## 普通炸弹使用爆炸组件

@onready var bomb_effect: BombEffectBase = $BombEffect

## 爆炸特效
func _start_bomb_fx():
	bomb_effect.activate_bomb_effect()

## 炸死所有敌人[僵尸有两个受击组件检测框,会被检测两次]
func _bomb_all_enemy():
	## 被爆炸炸到的敌人
	var character_be_bomb :Array[Character000Base] = []
	var areas = area_2d_bomb.get_overlapping_areas()
	for area in areas:
		var area_owner = area.owner
		if area_owner is Plant000Base:
			var plant:Plant000Base = area_owner as Plant000Base
			if plant.curr_be_attack_status & can_attack_plant_status:
				if not character_be_bomb.has(plant):
					if judge_lane(plant):
						character_be_bomb.append(plant)
		if area_owner is Zombie000Base:
			var zombie:Zombie000Base = area_owner as Zombie000Base
			if zombie.curr_be_attack_status & can_attack_zombie_status:
				if not character_be_bomb.has(zombie):
					if judge_lane(zombie):
						character_be_bomb.append(zombie)
		## 如果是梯子
		if area_owner is Ladder:
			if bomb_lane == -1 or (owner.lane + bomb_lane >= area_owner.lane and owner.lane - bomb_lane <= area_owner.lane ):
				area_owner.ladder_death()
	for c:Character000Base in character_be_bomb:
		if c is Zombie000Base:
			c.be_bomb(bomb_value, is_cherry_bomb)


func judge_lane(enemy:Character000Base) -> bool:
	return bomb_lane == -1 or (owner.lane + bomb_lane >= enemy.lane and owner.lane - bomb_lane <= enemy.lane )
