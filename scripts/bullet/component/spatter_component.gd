extends Node2D
class_name SpatterComponent
## 子弹溅射伤害组件

@onready var area_2d_spatter: Area2D = $Area2DSpatter

## 总溅射伤害
@export var sum_attack_value:int=40
## 溅射伤害范围
@export var range_attack_value:Vector2i=Vector2i(1, 13)
## 溅射到的上下行,默认为-1,无关行属性
@export var spatter_lane_up_down := -1
@export_group("攻击相关")
## 可以攻击的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺", "8 低矮") var can_attack_plant_status:int = 9
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下") var can_attack_zombie_status:int = 1

## 溅射伤害
func spatter_all_area_zombie(direct_hit_enemy: Character000Base, lane: int = -1) -> void:
	var areas = area_2d_spatter.get_overlapping_areas()
	var all_splatter_enemy: Array[Character000Base] = []
	var splatter_boss: ZombossBoss = null
	for area in areas:
		var owner_node = area.owner
		if owner_node == direct_hit_enemy:
			continue
		if owner_node is ZombossBoss:
			var boss := owner_node as ZombossBoss
			if boss.is_head_vulnerable:
				splatter_boss = boss
			continue
		if not owner_node is Character000Base:
			continue
		var enemy := owner_node as Character000Base
		## 如果不是可攻击状态敌人 植物
		if enemy is Plant000Base and not enemy.curr_be_attack_status & can_attack_plant_status:
			continue

		if enemy is Zombie000Base and not enemy.curr_be_attack_status & can_attack_zombie_status:
			continue

		all_splatter_enemy.append(enemy)
	var target_count := all_splatter_enemy.size() + (1 if splatter_boss != null else 0)
	if target_count == 0:
		return
	var damage_per_enemy: int = clampi(
		int(float(sum_attack_value) / target_count),
		range_attack_value.x,
		range_attack_value.y
	)
	for enemy in all_splatter_enemy:
		if spatter_lane_up_down == -1 or lane == -1 or (lane + spatter_lane_up_down >= enemy.lane and lane - spatter_lane_up_down <= enemy.lane):
			attack_enemy(enemy, damage_per_enemy)
	if splatter_boss != null:
		splatter_boss.be_attacked_bullet(damage_per_enemy, Global.AttackMode.Penetration, true, false)

func attack_enemy(enemy:Character000Base, damage_per_enemy:int):
	enemy.be_attacked_bullet(damage_per_enemy, Global.AttackMode.Penetration, true, false)
